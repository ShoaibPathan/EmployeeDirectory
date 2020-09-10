//
//  EmployeeListErrorViewController.swift
//  EmployeeDirectory
//
//  Created by Patrick Maltagliati on 9/9/20.
//  Copyright © 2020 Patrick Maltagliati. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class EmployeeListMessageViewController: UIViewController {
    private let imageView = UIImageView()
    private let label = UILabel()
    private let button = UIButton()
    private let disposeBag = DisposeBag()
    private let message: String

    init(message: String, retryObserver: AnyObserver<Void>) {
        self.message = message
        button.rx.tap.subscribe(retryObserver).disposed(by: disposeBag)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let config = UIImage.SymbolConfiguration(scale: .large)
        imageView.image = UIImage(systemName: "message", withConfiguration: config)
        imageView.tintColor = .systemBlue

        label.text = message
        label.font = UIFont.systemFont(ofSize: 16, weight: .light)
        label.numberOfLines = 0
        label.textAlignment = .center

        button.setTitle("Retry", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)

        view.addSubview(imageView)
        view.addSubview(label)
        view.addSubview(button)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -18).isActive = true

        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true

        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 18).isActive = true
    }
}
