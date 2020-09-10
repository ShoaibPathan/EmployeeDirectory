//
//  EmployeeListLoadingViewController.swift
//  EmployeeDirectory
//
//  Created by Patrick Maltagliati on 9/9/20.
//  Copyright © 2020 Patrick Maltagliati. All rights reserved.
//

import UIKit

class EmployeeListLoadingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
