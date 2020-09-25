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

class EmployeeListModel: NSObject, EmployeeListModelProtocol {
    private let dataStack: DataStackProtocol
    private let employeeListEndpoint: EmployeeListEndpointProtocol
    private let scheduler: SchedulerType
    private let disposeBag = DisposeBag()
    private let employeesRelay = BehaviorRelay<[Employee]>(value: [])
    private let imageDownloader = ImageDownloader()
    private let imageRelay = BehaviorRelay<(UUID, UIImage, URL)?>(value: nil)
    private var loadingImages = Set<UUID>()
    private let issueRelay = PublishRelay<Issue>()
    private lazy var imageContext: NSManagedObjectContext = {
        let context = dataStack.persistentContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return context
    }()

    private lazy var employeesFetchedResultsContext: NSManagedObjectContext = {
        let context = dataStack.persistentContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        return context
    }()

    private lazy var employeesFetchedResultsController: NSFetchedResultsController<EmployeeMO> = {
        let request: NSFetchRequest<EmployeeMO> = EmployeeMO.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "fullName", ascending: true)]
        let controller = NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: employeesFetchedResultsContext,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        controller.delegate = self
        return controller
    }()

    private let snapshotRelay = BehaviorRelay<NSDiffableDataSourceSnapshot<Section, Item>?>(value: nil)
    var snapshot: Observable<NSDiffableDataSourceSnapshot<Section, Item>> {
        snapshotRelay.compactMap { $0 }.asObservable()
    }

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
        super.init()

        Observable
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
            .filter { !$0.itemIdentifiers.isEmpty }
            .subscribe { [weak self] event in
                guard case let .next(snapshot) = event else { return }
                self?.snapshotRelay.accept(snapshot)
            }
            .disposed(by: disposeBag)

        do {
            try employeesFetchedResultsController.performFetch()
            employeesFetchedResultsContext.perform { [weak self] in
                guard let employees = self?.employeesFetchedResultsController.fetchedObjects?.compactMap(Employee.init) else { return }
                self?.employeesRelay.accept(employees)
            }
        } catch {
            issueRelay.accept(.error(error))
        }

        imageRelay
            .compactMap { $0 }
            .observeOn(scheduler)
            .subscribe { [weak self] event in
                guard case let .next(values) = event else { return }
                let (_, image, url) = values
                guard let context = self?.imageContext else { return }
                context.perform {
                    let imageManagedObject = ImageMO(context: context)
                    imageManagedObject.id = url.absoluteString
                    imageManagedObject.value = image
                }
            }
            .disposed(by: disposeBag)

        imageRelay
            .compactMap { $0 }
            .debounce(.seconds(3), scheduler: scheduler)
            .observeOn(scheduler)
            .subscribe { [weak self] _ in
                guard let context = self?.imageContext else { return }
                context.perform {
                    guard context.hasChanges else { return }
                    do {
                        try context.save()
                    } catch {
                        print(error)
                    }
                }
            }
            .disposed(by: disposeBag)

        issueRelay
            .subscribe { [weak self] event in
                guard case .next = event else { return }
                self?.snapshotRelay.accept(.empty)
            }
            .disposed(by: disposeBag)
    }

    func load(_ version: EmployeeListEndpoint.Version) {
        employeeListEndpoint
            .load(version)
            .delaySubscription(.milliseconds(Int.random(in: 300 ... 3000)), scheduler: scheduler)
            .observeOn(scheduler)
            .subscribe(
                onSuccess: { [weak self] employees in
                    guard !employees.isEmpty else {
                        self?.issueRelay.accept(.empty)
                        return
                    }
                    self?.persistEmployees(employees)
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
                    self?.imageContext.perform {
                        if let image = try? self?.imageContext.fetch(fetchRequest).first?.value as? UIImage {
                            self?.imageRelay.accept((id, image, url))
                        } else {
                            self?.loadSmallPhotoForItemWith(id: id, url: url)
                        }
                    }
                },
                onError: nil
            )
            .disposed(by: disposeBag)
    }

    private func loadSmallPhotoForItemWith(id: UUID, url: URL) {
        imageDownloader
            .download(url: url)
            /// Uncomment to add delay to image downloads to simulate a slower network
            .delaySubscription(.milliseconds(Int.random(in: 300 ... 3000)), scheduler: scheduler)
            .map { image in (id, image, url) }
            .observeOn(scheduler)
            .subscribe(
                onSuccess: { [weak self] values in self?.imageRelay.accept(values) },
                onError: nil
            )
            .disposed(by: disposeBag)
    }

    func persistEmployees(_ employees: [Employee]) {
        dataStack.persistentContainer.performBackgroundTask { [weak self] context in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            employees.forEach { EmployeeMO.create(from: $0, context: context) }
            do {
                try context.save()
            } catch {
                self?.issueRelay.accept(.error(error))
            }
        }
    }
}

extension EmployeeListModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        employeesFetchedResultsContext.perform { [weak self] in
            guard let results = controller.fetchedObjects as? [EmployeeMO] else { return }
            self?.employeesRelay.accept(results.compactMap(Employee.init))
        }
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

private extension EmployeeMO {
    static func create(from employee: Employee, context: NSManagedObjectContext) {
        let employeeMO = EmployeeMO(context: context)
        employeeMO.uuid = employee.uuid.uuidString
        employeeMO.fullName = employee.fullName
        employeeMO.phoneNumber = employee.phoneNumber
        employeeMO.emailAddress = employee.emailAddress
        employeeMO.biography = employee.biography
        employeeMO.photoSmall = employee.photoSmall
        employeeMO.photoLarge = employee.photoLarge
        employeeMO.team = employee.team
        employeeMO.classification = employee.classification.rawValue
    }
}

private extension Employee {
    init?(_ employeeMO: EmployeeMO) {
        guard
            let uuidString = employeeMO.uuid,
            let uuid = UUID(uuidString: uuidString),
            let fullName = employeeMO.fullName,
            let emailAddress = employeeMO.emailAddress,
            let team = employeeMO.team,
            let classificationRawValue = employeeMO.classification,
            let classification = Employee.Classification(rawValue: classificationRawValue)
        else { return nil }
        self.uuid = uuid
        self.fullName = fullName
        phoneNumber = employeeMO.phoneNumber
        self.emailAddress = emailAddress
        biography = employeeMO.biography
        photoSmall = employeeMO.photoSmall
        photoLarge = employeeMO.photoLarge
        self.team = team
        self.classification = classification
    }
}
