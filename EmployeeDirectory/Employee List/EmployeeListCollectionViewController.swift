//
//  EmployeeListCollectionViewController.swift
//  EmployeeDirectory
//
//  Created by Patrick Maltagliati on 9/8/20.
//  Copyright © 2020 Patrick Maltagliati. All rights reserved.
//

import RxSwift
import UIKit

class EmployeeListCollectionViewController: UICollectionViewController {
    private let loadImageObserver: AnyObserver<EmployeeListModel.Item>
    private let selectedEmployeeObserver: AnyObserver<UUID>
    private var dataSource: DataSource?

    init(loadImageObserver: AnyObserver<EmployeeListModel.Item>, selectedEmployeeObserver: AnyObserver<UUID>) {
        self.loadImageObserver = loadImageObserver
        self.selectedEmployeeObserver = selectedEmployeeObserver
        super.init(collectionViewLayout: UICollectionViewLayout.layout)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = UIColor.systemBackground
        collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)
        let dataSource = EmployeeListCollectionViewController.DataSource.dataSource(with: collectionView)
        collectionView.dataSource = dataSource
        self.dataSource = dataSource
    }

    override func collectionView(_: UICollectionView, willDisplay _: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let item = dataSource?.itemIdentifier(for: indexPath) else { return }
        loadImageObserver.onNext(item)
    }

    override func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let id = dataSource?.itemIdentifier(for: indexPath)?.id else { return }
        selectedEmployeeObserver.onNext(id)
    }

    func apply(snapshot: EmployeeListModel.Snapshot) {
        dataSource?.apply(snapshot, animatingDifferences: true, completion: nil)
    }
}

extension EmployeeListCollectionViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<EmployeeListModel.Section, EmployeeListModel.Item>
}

private extension EmployeeListCollectionViewController {
    class Cell: UICollectionViewCell {
        static let reuseIdentifier = String(describing: EmployeeListCollectionViewController.Cell.self)
        private let imageView = UIImageView()
        private let titleLabel = UILabel()
        private let subtitleLabel = UILabel()

        override init(frame: CGRect) {
            super.init(frame: frame)

            titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            subtitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
            subtitleLabel.minimumScaleFactor = 0.4
            subtitleLabel.adjustsFontSizeToFitWidth = true

            let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = 2

            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 28

            contentView.addSubview(imageView)
            contentView.addSubview(stackView)

            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 56).isActive = true
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true

            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.topAnchor.constraint(greaterThanOrEqualTo: imageView.bottomAnchor, constant: 4).isActive = true
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4).isActive = true
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4).isActive = true

            let view = UIView()
            view.layer.cornerRadius = 15
            view.layer.masksToBounds = false
            view.backgroundColor = .secondarySystemBackground
            backgroundView = view
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func update(item: EmployeeListModel.Item) {
            imageView.image = item.image
            titleLabel.text = item.title
            subtitleLabel.text = item.subtitle
        }
    }
}

private extension EmployeeListCollectionViewController.DataSource {
    static func dataSource(with collectionView: UICollectionView) -> EmployeeListCollectionViewController.DataSource {
        EmployeeListCollectionViewController.DataSource(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmployeeListCollectionViewController.Cell.reuseIdentifier, for: indexPath)
            (cell as? EmployeeListCollectionViewController.Cell)?.update(item: item)
            return cell
        }
    }
}

private extension UICollectionViewLayout {
    static var layout: UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { (section, _) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(120))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 0, trailing: 10)
            return section
        }
    }
}
