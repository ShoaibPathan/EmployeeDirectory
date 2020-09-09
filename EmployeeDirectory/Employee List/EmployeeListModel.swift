//
//  EmployeeListModel.swift
//  EmployeeDirectory
//
//  Created by Patrick Maltagliati on 9/8/20.
//  Copyright © 2020 Patrick Maltagliati. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

protocol EmployeeListModelProtocol {
    var snapshot: Observable<EmployeeListModel.Snapshot>  { get }
    func load(_ version: EmployeeListEndpoint.Version)
}

class EmployeeListModel: EmployeeListModelProtocol {
    private let snapshotRelay: BehaviorRelay<NSDiffableDataSourceSnapshot<Section, Item>>
    private let employeeListEndpoint: EmployeeListEndpointProtocol
    private let scheduler: SchedulerType
    private let disposeBag = DisposeBag()
    
    var snapshot: Observable<NSDiffableDataSourceSnapshot<Section, Item>> {
        snapshotRelay.asObservable()
    }
    
    init(employeeListEndpoint: EmployeeListEndpointProtocol = EmployeeListEndpoint(),
         scheduler: SchedulerType = SerialDispatchQueueScheduler(qos: .userInteractive)) {
        self.snapshotRelay = BehaviorRelay(value: NSDiffableDataSourceSnapshot<Section, Item>.empty)
        self.employeeListEndpoint = employeeListEndpoint
        self.scheduler = scheduler
    }
    
    func load(_ version: EmployeeListEndpoint.Version) {
        employeeListEndpoint
            .load(version)
            .observeOn(scheduler)
            .subscribe(
                onSuccess: { [weak self] employees in
                    guard let relay = self?.snapshotRelay else {
                        return
                    }
                    let items = employees.map { employee in
                        EmployeeListModel.Item(id: employee.uuid,
                                               title: employee.fullName,
                                               subtitle: employee.team,
                                               image: UIImage.placeholder)
                        
                    }
                    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>.empty
                    snapshot.appendItems(items, toSection: .main)
                    relay.accept(snapshot)
                },
                onError: { _ in }) /// TODO: Handle Error
            .disposed(by: disposeBag)
    }
}

extension EmployeeListModel {
    typealias Snapshot = NSDiffableDataSourceSnapshot<EmployeeListModel.Section, EmployeeListModel.Item>
    
    enum Section {
        case main
    }
    
    struct Item: Hashable {
        let id: UUID
        let title: String
        let subtitle: String
        let image: UIImage
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: Item, rhs: Item) -> Bool {
            lhs.id == rhs.id
        }
    }
}

private extension NSDiffableDataSourceSnapshot where SectionIdentifierType == EmployeeListModel.Section, ItemIdentifierType == EmployeeListModel.Item {
    static var empty: Self {
        var snapshot = Self()
        snapshot.appendSections([.main])
        return snapshot
    }
}

private extension UIImage {
    static var placeholder: UIImage {
        UIImage(systemName: "person.circle") ?? UIImage()
    }
}
