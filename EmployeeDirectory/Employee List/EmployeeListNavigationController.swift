//
//  EmployeeListNavigationController.swift
//  EmployeeDirectory
//
//  Created by Patrick Maltagliati on 9/8/20.
//  Copyright © 2020 Patrick Maltagliati. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class EmployeeListNavigationController: UINavigationController {
    private let dataStack: DataStackProtocol
    private let idRelay = PublishSubject<UUID>()
    private let disposeBag = DisposeBag()

    init(dataStack: DataStackProtocol) {
        self.dataStack = dataStack
        super.init(rootViewController: EmployeeListContainerViewController(dataStack: dataStack,
                                                                           selectedEmployeeObserver: idRelay.asObserver()))
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.prefersLargeTitles = true

        idRelay
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] event in
                guard let self = self else { return }
                guard case let .next(id) = event else { return }
                let viewController = EmployeeDetailViewController(dataStack: self.dataStack, selectedEmployeeId: id)
                self.pushViewController(viewController, animated: true)
            }
            .disposed(by: disposeBag)
    }
}
