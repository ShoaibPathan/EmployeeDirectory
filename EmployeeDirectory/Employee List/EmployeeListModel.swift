//
//  EmployeeListModel.swift
//  EmployeeDirectory
//
//  Created by Patrick Maltagliati on 9/8/20.
//  Copyright © 2020 Patrick Maltagliati. All rights reserved.
//

import RxRelay
import RxSwift
import UIKit

protocol EmployeeListModelProtocol {
    var snapshot: Observable<EmployeeListModel.Snapshot> { get }
    var loadImageObserver: AnyObserver<EmployeeListModel.Item> { get }
    func load(_ version: EmployeeListEndpoint.Version)
}

class EmployeeListModel: EmployeeListModelProtocol {
    let snapshot: Observable<NSDiffableDataSourceSnapshot<Section, Item>>
    private let employeeListEndpoint: EmployeeListEndpointProtocol
    private let scheduler: SchedulerType
    private let disposeBag = DisposeBag()
    private let employeesRelay = BehaviorRelay<[Employee]>(value: [])
    private let imageDownloader = ImageDownloader()
    private let imageRelay = BehaviorRelay<(UUID, UIImage)?>(value: nil)
    private var loadingImages = Set<UUID>()

    var loadImageObserver: AnyObserver<EmployeeListModel.Item> {
        AnyObserver<EmployeeListModel.Item> { [weak self] event in
            guard case let .next(item) = event else { return }
            guard let self = self else { return }
            let id = item.id
            guard !self.loadingImages.contains(id) else { return }
            self.loadingImages.insert(id)
            self.loadSmallPhotoForItemWith(id: item.id)
        }
    }

    init(employeeListEndpoint: EmployeeListEndpointProtocol = EmployeeListEndpoint(),
         scheduler: SchedulerType = SerialDispatchQueueScheduler(qos: .userInteractive))
    {
        self.employeeListEndpoint = employeeListEndpoint
        self.scheduler = scheduler
        snapshot = Observable
            .combineLatest(employeesRelay, imageRelay)
            .scan(NSDiffableDataSourceSnapshot<Section, Item>.empty) { (previousSnapshot, values) -> NSDiffableDataSourceSnapshot<Section, Item> in
                var newSnapshot = NSDiffableDataSourceSnapshot<Section, Item>.empty
                let (employees, imageValues) = values
                let items = employees.map { (employee: Employee) -> Item in
                    let id = employee.uuid
                    let title = employee.fullName
                    let subtitle = employee.team
                    let image: UIImage
                    if let (newImageId, newImage) = imageValues, id == newImageId {
                        image = newImage
                    } else if let existingImage = previousSnapshot.itemIdentifiers.first(where: { $0.id == id })?.image {
                        image = existingImage
                    } else {
                        image = UIImage.placeholder
                    }
                    return Item(id: id, title: title, subtitle: subtitle, image: image)
                }
                newSnapshot.appendItems(items, toSection: .main)
                return newSnapshot
            }
    }

    func load(_ version: EmployeeListEndpoint.Version) {
        employeeListEndpoint
            .load(version)
            .observeOn(scheduler)
            .subscribe(
                onSuccess: { [weak self] employees in
                    self?.employeesRelay.accept(employees)
                },
                onError: { _ in }
            ) // TODO: Handle Error
            .disposed(by: disposeBag)
    }

    private func loadSmallPhotoForItemWith(id: UUID) {
        employeesRelay
            .take(1)
            .compactMap { (employees: [Employee]) -> Employee? in employees.first(where: { $0.uuid == id }) }
            .compactMap { (employee: Employee) -> (UUID, URL)? in
                guard let url = employee.photoSmall else { return nil }
                return (employee.uuid, url)
            }
            .flatMap { [weak self] (employee: (UUID, URL)) -> Single<(UUID, UIImage)> in
                self?.imageDownloader
                    .download(url: employee.1)
                    .delaySubscription(.milliseconds(Int.random(in: 300 ... 3000)), scheduler: MainScheduler.instance)
                    .map { image in (employee.0, image) } ?? Single.never()
            }
            .asSingle()
            .subscribe(
                onSuccess: { [weak self] values in
                    self?.imageRelay.accept(values)
                },
                onError: nil
            )
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
