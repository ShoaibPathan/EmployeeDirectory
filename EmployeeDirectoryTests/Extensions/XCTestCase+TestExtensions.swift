//
//  XCTestCase+TestExtensions.swift
//  EmployeeDirectoryTests
//
//  Created by Patrick Maltagliati on 9/8/20.
//  Copyright © 2020 Patrick Maltagliati. All rights reserved.
//

import UIKit
import XCTest

extension XCTestCase {
    @discardableResult
    func make(rootViewController: UIViewController?) -> UIViewController? {
        guard let rootViewController = rootViewController else {
            return nil
        }
        let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
        let previousRootViewController = keyWindow?.rootViewController
        keyWindow?.rootViewController = rootViewController
        return previousRootViewController
    }
}
