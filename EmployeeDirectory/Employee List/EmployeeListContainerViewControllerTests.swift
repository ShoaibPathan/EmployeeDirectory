//
//  EmployeeListContainerViewControllerTests.swift
//  EmployeeDirectoryTests
//
//  Created by Patrick Maltagliati on 9/8/20.
//  Copyright © 2020 Patrick Maltagliati. All rights reserved.
//

import XCTest

class EmployeeListContainerViewControllerTests: XCTestCase {
    private var testObject: EmployeeListContainerViewController!
    private var previousRootViewController: UIViewController!

    override func setUpWithError() throws {
        testObject = EmployeeListContainerViewController(dataStack: DataStackProtocolMock())
        previousRootViewController = make(rootViewController: testObject)
    }

    override func tearDownWithError() throws {
        make(rootViewController: previousRootViewController)
    }

    func testCollectionViewControllerIsAChildViewController() throws {
        XCTAssertNotNil(testObject.firstChildViewController(ofType: EmployeeListCollectionViewController.self))
    }
}
