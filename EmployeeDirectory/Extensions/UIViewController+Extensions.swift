//
//  UIViewController+Extensions.swift
//  EmployeeDirectory
//
//  Created by Patrick Maltagliati on 9/8/20.
//  Copyright © 2020 Patrick Maltagliati. All rights reserved.
//

import UIKit

extension UIViewController {
    func add(_ child: UIViewController, container: UIView? = nil) {
        addChild(child)
        (container ?? view).addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func pinToEdges(of container: UIView, edgeInsets insets: UIEdgeInsets = .zero) {
        view.pinToEdges(of: container, edgeInsets: insets)
    }
}
