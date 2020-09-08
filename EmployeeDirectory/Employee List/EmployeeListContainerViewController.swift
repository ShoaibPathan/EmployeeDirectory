//
//  EmployeeListContainerViewController.swift
//  EmployeeDirectory
//
//  Created by Patrick Maltagliati on 9/8/20.
//  Copyright © 2020 Patrick Maltagliati. All rights reserved.
//

import UIKit

class EmployeeListContainerViewController: UIViewController {
    private let listCollectionViewController = EmployeeListCollectionViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Employees"
        
        add(listCollectionViewController)
        listCollectionViewController.pinToEdges(of: view)
    }
}
