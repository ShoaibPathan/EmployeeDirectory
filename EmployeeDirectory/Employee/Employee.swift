//
//  Employee.swift
//  EmployeeDirectory
//
//  Created by Patrick Maltagliati on 9/8/20.
//  Copyright © 2020 Patrick Maltagliati. All rights reserved.
//

import Foundation

struct Employee: Codable, Equatable {
    let uuid: UUID
    let fullName: String
    let phoneNumber: String?
    let emailAddress: String
    let biography: String?
    let photoSmall: URL?
    let photoLarge: URL?
    let team: String
    let classification: Employee.Classification
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case fullName = "full_name"
        case phoneNumber = "phone_number"
        case emailAddress = "email_address"
        case biography
        case photoSmall = "photo_url_small"
        case photoLarge = "photo_url_large"
        case team
        case classification = "employee_type"
    }
}

extension Employee {
    enum Classification: String, Codable, CaseIterable {
        case fullTime = "FULL_TIME"
        case partTime = "PART_TIME"
        case contractor = "CONTRACTOR"
    }
}
