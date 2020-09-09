//
//  EmployeeListNavigationController.swift
//  EmployeeDirectory
//
//  Created by Patrick Maltagliati on 9/8/20.
//  Copyright © 2020 Patrick Maltagliati. All rights reserved.
//

import UIKit

class EmployeeListNavigationController: UINavigationController {
    init() {
        super.init(rootViewController: EmployeeListContainerViewController())
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.prefersLargeTitles = true
    }
}
