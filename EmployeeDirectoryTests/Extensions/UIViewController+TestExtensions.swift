//
//  UIViewController+TestExtensions.swift
//  EmployeeDirectoryTests
//
//  Created by Patrick Maltagliati on 9/8/20.
//  Copyright © 2020 Patrick Maltagliati. All rights reserved.
//

import UIKit

extension UIViewController {
    func firstChildViewController<T: UIViewController>(ofType _: T.Type) -> T? {
        children.compactMap { $0 as? T }.first
    }
}
