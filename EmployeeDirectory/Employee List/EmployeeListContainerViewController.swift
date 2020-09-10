//
//  EmployeeListContainerViewController.swift
//  EmployeeDirectory
//
//  Created by Patrick Maltagliati on 9/8/20.
//  Copyright © 2020 Patrick Maltagliati. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class EmployeeListContainerViewController: UIViewController {
    private let employeeListModel: EmployeeListModel
    private let listCollectionViewController: EmployeeListCollectionViewController
    private let retryRelay: PublishRelay<Void>
    private let loadingViewController = EmployeeListLoadingViewController()
    private let errorViewController: EmployeeListMessageViewController
    private let emptyViewController: EmployeeListMessageViewController
    private var disposeBag = DisposeBag()

    init(dataStack: DataStackProtocol) {
        let retryRelay = PublishRelay<Void>()
        let retryObserver = AnyObserver<Void>(eventHandler: { _ in retryRelay.accept(()) })
        employeeListModel = EmployeeListModel(dataStack: dataStack)
        listCollectionViewController = EmployeeListCollectionViewController(loadImageObserver: employeeListModel.loadImageObserver)
        errorViewController = EmployeeListMessageViewController(message: "Sorry, something went wrong...", retryObserver: retryObserver)
        emptyViewController = EmployeeListMessageViewController(message: "No Employees... Maybe Hire Pat? 😉", retryObserver: retryObserver)
        self.retryRelay = retryRelay
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Employees"

        add(listCollectionViewController)
        listCollectionViewController.pinToEdges(of: view)

        add(loadingViewController)
        loadingViewController.pinToEdges(of: view)

        add(errorViewController)
        errorViewController.pinToEdges(of: view)

        add(emptyViewController)
        errorViewController.pinToEdges(of: view)

        prepareSubscription()
    }

    private func prepareSubscription() {
        disposeBag = DisposeBag()

        loadingViewController.view.isHidden = false
        errorViewController.view.isHidden = true
        emptyViewController.view.isHidden = true

        employeeListModel
            .snapshot
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] event in
                guard case let .next(snapshot) = event else { return }
                self?.listCollectionViewController.apply(snapshot: snapshot)
                self?.loadingViewController.view.isHidden = true
                self?.errorViewController.view.isHidden = true
            }
            .disposed(by: disposeBag)

        employeeListModel
            .issue
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] event in
                self?.loadingViewController.view.isHidden = true
                guard case let .next(issue) = event else { return }
                switch issue {
                case .error:
                    self?.errorViewController.view.isHidden = false
                case .empty:
                    self?.emptyViewController.view.isHidden = false
                }
            }
            .disposed(by: disposeBag)

        retryRelay
            .subscribeOn(MainScheduler.instance)
            .subscribe { [weak self] event in
                guard case .next = event else { return }
                self?.prepareSubscription()
            }
            .disposed(by: disposeBag)

        let version = EmployeeListEndpoint.Version.allCases.randomElement() ?? .success
        employeeListModel.load(version)
    }
}
