//
//  EmployeeListContainerViewController.swift
//  EmployeeDirectory
//
//  Created by Patrick Maltagliati on 9/8/20.
//  Copyright © 2020 Patrick Maltagliati. All rights reserved.
//

import RxSwift
import UIKit

class EmployeeListContainerViewController: UIViewController {
    private let employeeListModel: EmployeeListModel
    private let listCollectionViewController: EmployeeListCollectionViewController
    private let disposeBag = DisposeBag()

    init(dataStack: DataStack) {
        employeeListModel = EmployeeListModel(dataStack: dataStack)
        listCollectionViewController = EmployeeListCollectionViewController(loadImageObserver: employeeListModel.loadImageObserver)
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

        employeeListModel
            .snapshot
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] event in
                guard case let .next(snapshot) = event else {
                    return
                }
                self?.listCollectionViewController.apply(snapshot: snapshot)
            }
            .disposed(by: disposeBag)

        employeeListModel.load(.success)
    }
}
