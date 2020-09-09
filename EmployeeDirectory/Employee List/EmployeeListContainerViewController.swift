//
//  EmployeeListContainerViewController.swift
//  EmployeeDirectory
//
//  Created by Patrick Maltagliati on 9/8/20.
//  Copyright © 2020 Patrick Maltagliati. All rights reserved.
//

import UIKit
import RxSwift

class EmployeeListContainerViewController: UIViewController {
    private let listCollectionViewController = EmployeeListCollectionViewController()
    private let employeeListModel = EmployeeListModel()
    private let disposeBag = DisposeBag()
    
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
