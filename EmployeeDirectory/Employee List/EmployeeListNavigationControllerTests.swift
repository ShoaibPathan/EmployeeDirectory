//
//  EmployeeListNavigationControllerTests.swift
//  EmployeeDirectoryTests
//
//  Created by Patrick Maltagliati on 9/8/20.
//  Copyright © 2020 Patrick Maltagliati. All rights reserved.
//

import XCTest

class EmployeeListNavigationControllerTests: XCTestCase {
    private var testObject: EmployeeListNavigationController!
    private var previousRootViewController: UIViewController!

    override func setUpWithError() throws {
        testObject = EmployeeListNavigationController()
        previousRootViewController = make(rootViewController: testObject)
    }

    override func tearDownWithError() throws {
        make(rootViewController: previousRootViewController)
    }

    func testCollectionViewControllerIsAChildViewController() throws {
        XCTAssertNotNil(testObject.firstChildViewController(ofType: EmployeeListContainerViewController.self))
    }
}
