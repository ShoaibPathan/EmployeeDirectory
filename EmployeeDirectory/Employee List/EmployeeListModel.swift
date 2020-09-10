//
//  EmployeeListModel.swift
//  EmployeeDirectory
//
//  Created by Patrick Maltagliati on 9/8/20.
//  Copyright © 2020 Patrick Maltagliati. All rights reserved.
//

import CoreData
import RxRelay
import RxSwift
import UIKit

protocol EmployeeListModelProtocol {
    var snapshot: Observable<EmployeeListModel.Snapshot> { get }
    var issue: Observable<EmployeeListModel.Issue> { get }
    var loadImageObserver: AnyObserver<EmployeeListModel.Item> { get }
    func load(_ version: EmployeeListEndpoint.Version)
}

class EmployeeListModel: EmployeeListModelProtocol {
    let snapshot: Observable<NSDiffableDataSourceSnapshot<Section, Item>>
    private let dataStack: DataStackProtocol
    private let employeeListEndpoint: EmployeeListEndpointProtocol
    private let scheduler: SchedulerType
    private let disposeBag = DisposeBag()
    private let employeesRelay = BehaviorRelay<[Employee]>(value: [])
    private let imageDownloader = ImageDownloader()
    private let imageRelay = BehaviorRelay<(UUID, UIImage, URL)?>(value: nil)
    private var loadingImages = Set<UUID>()
    private let issueRelay = PublishRelay<Issue>()

    var loadImageObserver: AnyObserver<EmployeeListModel.Item> {
        AnyObserver<EmployeeListModel.Item> { [weak self] event in
            guard case let .next(item) = event else { return }
            guard let self = self else { return }
            let id = item.id
            guard !self.loadingImages.contains(id) else { return }
            self.loadingImages.insert(id)
            self.getSmallPhotoFromCacheOrLoadFromUrlForItemWith(id: item.id)
        }
    }

    var issue: Observable<EmployeeListModel.Issue> { issueRelay.asObservable() }

    init(dataStack: DataStackProtocol,
         employeeListEndpoint: EmployeeListEndpointProtocol = EmployeeListEndpoint(),
         scheduler: SchedulerType = SerialDispatchQueueScheduler(qos: .userInteractive))
    {
        self.dataStack = dataStack
        self.employeeListEndpoint = employeeListEndpoint
        self.scheduler = scheduler
        snapshot = Observable
            .combineLatest(employeesRelay, imageRelay)
            .subscribeOn(scheduler)
            .scan(NSDiffableDataSourceSnapshot<Section, Item>.empty) { (previousSnapshot, values) -> NSDiffableDataSourceSnapshot<Section, Item> in
                var newSnapshot = NSDiffableDataSourceSnapshot<Section, Item>.empty
                let (employees, imageValues) = values
                let items = employees.sorted(by: { $0.fullName < $1.fullName }).map { (employee: Employee) -> Item in
                    let id = employee.uuid
                    let title = employee.fullName
                    let subtitle = employee.team
                    let image: UIImage
                    if let (newImageId, newImage, _) = imageValues, id == newImageId {
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

        imageRelay
            .compactMap { $0 }
            .observeOn(scheduler)
            .subscribe { [weak self] event in
                guard case let .next(values) = event else { return }
                let (_, image, url) = values
                guard let context = self?.dataStack.persistentContainer.viewContext else { return }
                guard let imageManagedObject = NSEntityDescription.insertNewObject(forEntityName: "Image", into: context) as? ImageMO else { return }
                imageManagedObject.id = url.absoluteString
                imageManagedObject.value = image
            }
            .disposed(by: disposeBag)

        imageRelay
            .compactMap { $0 }
            .debounce(.seconds(3), scheduler: scheduler)
            .observeOn(scheduler)
            .subscribe { [weak self] _ in
                self?.dataStack.saveContext()
            }
            .disposed(by: disposeBag)
    }

    func load(_ version: EmployeeListEndpoint.Version) {
        employeeListEndpoint
            .load(version)
            .observeOn(scheduler)
            .subscribe(
                onSuccess: { [weak self] employees in
                    guard !employees.isEmpty else {
                        self?.issueRelay.accept(.empty)
                        return
                    }
                    self?.employeesRelay.accept(employees)
                },
                onError: { [weak self] error in
                    self?.issueRelay.accept(.error(error))
                }
            )
            .disposed(by: disposeBag)
    }

    private func getSmallPhotoFromCacheOrLoadFromUrlForItemWith(id: UUID) {
        employeesRelay
            .take(1)
            .compactMap { (employees: [Employee]) -> Employee? in employees.first(where: { $0.uuid == id }) }
            .compactMap { (employee: Employee) -> (UUID, URL)? in
                guard let url = employee.photoSmall else { return nil }
                return (employee.uuid, url)
            }
            .asSingle()
            .observeOn(scheduler)
            .subscribe(
                onSuccess: { [weak self] values in
                    let (id, url) = values
                    let fetchRequest = NSFetchRequest<ImageMO>(entityName: "Image")
                    fetchRequest.predicate = NSPredicate(format: "id = %@", url.absoluteString)
                    let context = self?.dataStack.persistentContainer.viewContext
                    if let image = try? context?.fetch(fetchRequest).first?.value as? UIImage {
                        self?.imageRelay.accept((id, image, url))
                    } else {
                        self?.loadSmallPhotoForItemWith(id: id, url: url)
                    }
                },
                onError: nil
            )
            .disposed(by: disposeBag)
    }

    private func loadSmallPhotoForItemWith(id: UUID, url: URL) {
        imageDownloader
            .download(url: url)
            .delaySubscription(.milliseconds(Int.random(in: 300 ... 3000)), scheduler: scheduler)
            .map { image in (id, image, url) }
            .observeOn(scheduler)
            .subscribe(
                onSuccess: { [weak self] values in self?.imageRelay.accept(values) },
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

    enum Issue {
        case error(Error)
        case empty
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
