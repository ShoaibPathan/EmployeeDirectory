//
//  EmployeeListModelTests.swift
//  EmployeeDirectoryTests
//
//  Created by Patrick Maltagliati on 9/8/20.
//  Copyright © 2020 Patrick Maltagliati. All rights reserved.
//

import RxSwift
import RxTest
import XCTest

class EmployeeListModelTests: XCTestCase {
    private var testObject: EmployeeListModel!
    private var mockEmployeeListEndpoint: EmployeeListEndpointProtocolMock!
    private var testScheduler: TestScheduler!
    private var observer: TestableObserver<EmployeeListModel.Snapshot>!
    private var disposeBag: DisposeBag!

    override func setUpWithError() throws {
        testScheduler = TestScheduler(initialClock: 0, resolution: 1, simulateProcessingDelay: false)
        observer = testScheduler.createObserver(EmployeeListModel.Snapshot.self)
        disposeBag = DisposeBag()
        mockEmployeeListEndpoint = EmployeeListEndpointProtocolMock()
        testObject = EmployeeListModel(employeeListEndpoint: mockEmployeeListEndpoint, scheduler: testScheduler)
        testObject.snapshot.subscribe(observer.asObserver()).disposed(by: disposeBag)
    }

    func testEndpointIsInvoked() throws {
        let employees = Employee.testMany
        let version = try XCTUnwrap(EmployeeListEndpoint.Version.allCases.randomElement())
        mockEmployeeListEndpoint.stubbedResponse = testScheduler.single(employees, at: 1)
        testObject.load(version)
        testScheduler.start()
        XCTAssertEqual(observer.events.count, 2)
        let snapshot = try XCTUnwrap(observer.events.last?.value.element)
        let numberOfItems = try XCTUnwrap(snapshot.numberOfItems(inSection: .main))
        XCTAssertEqual(snapshot.numberOfSections, 1)
        XCTAssertEqual(numberOfItems, employees.count)
        try snapshot.itemIdentifiers.forEach { item in
            let employee = try XCTUnwrap(employees.first(where: { $0.uuid == item.id }))
            XCTAssertEqual(item.title, employee.fullName)
            XCTAssertEqual(item.subtitle, employee.team)
        }
    }
}

private extension EmployeeListModelTests {
    class EmployeeListEndpointProtocolMock: EmployeeListEndpointProtocol {
        private(set) var versionList = [EmployeeListEndpoint.Version]()
        var stubbedResponse: Single<[Employee]>?

        func load(_ version: EmployeeListEndpoint.Version) -> Single<[Employee]> {
            versionList.append(version)
            return stubbedResponse ?? .never()
        }
    }
}

private extension TestScheduler {
    func single<T>(_ value: T, at time: TestTime) -> Single<T> {
        createColdObservable([Recorded.next(time - 1, value), Recorded.completed(time)]).asSingle()
    }
}
