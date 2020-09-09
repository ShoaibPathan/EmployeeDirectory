//
//  Employee+TestExtensions.swift
//  EmployeeDirectoryTests
//
//  Created by Patrick Maltagliati on 9/8/20.
//  Copyright © 2020 Patrick Maltagliati. All rights reserved.
//

import XCTest
import Foundation

extension Employee {
    static var test: Employee {
        Employee(
            uuid: UUID(),
            fullName: UUID().uuidString,
            phoneNumber: UUID().uuidString,
            emailAddress: UUID().uuidString,
            biography: UUID().uuidString,
            photoSmall: URL(string: UUID().uuidString),
            photoLarge: URL(string: UUID().uuidString),
            team: UUID().uuidString,
            classification: Employee.Classification.allCases.randomElement() ?? .contractor
        )
    }
    
    static var testMany: [Employee] {
        (0...Int.random(in: 3...6)).map { _ in Employee.test }
    }
}
