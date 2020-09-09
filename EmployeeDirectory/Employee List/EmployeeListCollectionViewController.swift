//
//  EmployeeListCollectionViewController.swift
//  EmployeeDirectory
//
//  Created by Patrick Maltagliati on 9/8/20.
//  Copyright © 2020 Patrick Maltagliati. All rights reserved.
//

import UIKit

class EmployeeListCollectionViewController: UICollectionViewController {
    private var dataSource: DataSource?
    
    init() {
        super.init(collectionViewLayout: UICollectionViewLayout.layout)
    }
    
    required init?(coder: NSCoder) {
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
            
            imageView.contentMode = .scaleAspectFit
            
            contentView.addSubview(imageView)
            contentView.addSubview(stackView)
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4).isActive = true
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4).isActive = true
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4).isActive = true
            
            let view = UIView()
            view.layer.cornerRadius = 15
            view.layer.masksToBounds = false
            view.backgroundColor = .secondarySystemBackground
            backgroundView = view
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            imageView.layer.cornerRadius = max(imageView.bounds.width, imageView.bounds.height) / 2
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
        UICollectionViewCompositionalLayout { (section, environment) -> NSCollectionLayoutSection? in
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
