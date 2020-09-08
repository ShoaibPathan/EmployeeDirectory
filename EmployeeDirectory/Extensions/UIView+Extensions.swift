//
//  UIView+Extensions.swift
//  EmployeeDirectory
//
//  Created by Patrick Maltagliati on 9/8/20.
//  Copyright © 2020 Patrick Maltagliati. All rights reserved.
//

import UIKit

extension UIView {
    func pinToEdges(of container: UIView, edgeInsets insets: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        leftAnchor.constraint(equalTo: container.leftAnchor, constant: insets.left).isActive = true
        rightAnchor.constraint(equalTo: container.rightAnchor, constant: -insets.right).isActive = true
        topAnchor.constraint(equalTo: container.topAnchor, constant: insets.top).isActive = true
        bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -insets.bottom).isActive = true
    }
}
