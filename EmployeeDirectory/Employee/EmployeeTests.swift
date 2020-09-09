//
//  EmployeeTests.swift
//  EmployeeDirectoryTests
//
//  Created by Patrick Maltagliati on 9/8/20.
//  Copyright © 2020 Patrick Maltagliati. All rights reserved.
//

import XCTest

class EmployeeTests: XCTestCase {
    private var uuid: UUID!
    private var fullName: String!
    private var phoneNumber: String!
    private var emailAddress: String!
    private var biography: String!
    private var photoSmall: URL!
    private var photoLarge: URL!
    private var team: String!
    private var classification: Employee.Classification!
    private var decoder: JSONDecoder!

    override func setUpWithError() throws {
        uuid = UUID()
        fullName = UUID().uuidString
        phoneNumber = UUID().uuidString
        emailAddress = UUID().uuidString
        biography = UUID().uuidString
        photoSmall = try XCTUnwrap(URL(string: UUID().uuidString))
        photoLarge = try XCTUnwrap(URL(string: UUID().uuidString))
        team = UUID().uuidString
        classification = try XCTUnwrap(Employee.Classification.allCases.randomElement())
        decoder = JSONDecoder()
    }

    func testCodable() throws {
        let input = Employee(uuid: uuid,
                             fullName: fullName,
                             phoneNumber: phoneNumber,
                             emailAddress: emailAddress,
                             biography: biography,
                             photoSmall: photoSmall,
                             photoLarge: photoLarge,
                             team: team,
                             classification: classification)
        let data = try JSONEncoder().encode(input)
        let testObject = try decoder.decode(Employee.self, from: data)
        XCTAssertEqual(testObject, input)
    }

    func testDecodable() throws {
        let json = """
        {
        "uuid" : "\(uuid.uuidString)",
        "full_name" : "\(fullName ?? "")",
        "phone_number" : "\(phoneNumber ?? "")",
        "email_address" : "\(emailAddress ?? "")",
        "biography" : "\(biography ?? "")",
        "photo_url_small" : "\(photoSmall.absoluteString)",
        "photo_url_large" : "\(photoLarge.absoluteString)",
        "team" : "\(team ?? "")",
        "employee_type" : "\(classification?.rawValue ?? "")"
        }
        """
        let testObject: Employee = try decoder.decode(Employee.self, from: Data(json.utf8))
        XCTAssertEqual(testObject.uuid, uuid)
        XCTAssertEqual(testObject.fullName, fullName)
        XCTAssertEqual(testObject.phoneNumber, phoneNumber)
        XCTAssertEqual(testObject.emailAddress, emailAddress)
        XCTAssertEqual(testObject.biography, biography)
        XCTAssertEqual(testObject.photoSmall, photoSmall)
        XCTAssertEqual(testObject.photoLarge, photoLarge)
        XCTAssertEqual(testObject.team, team)
        XCTAssertEqual(testObject.classification, classification)
    }

    func testDecodableWithoutPhoneNumber() throws {
        let json = """
        {
        "uuid" : "\(uuid.uuidString)",
        "full_name" : "\(fullName ?? "")",
        "email_address" : "\(emailAddress ?? "")",
        "biography" : "\(biography ?? "")",
        "photo_url_small" : "\(photoSmall.absoluteString)",
        "photo_url_large" : "\(photoLarge.absoluteString)",
        "team" : "\(team ?? "")",
        "employee_type" : "\(classification?.rawValue ?? "")"
        }
        """
        let testObject: Employee = try decoder.decode(Employee.self, from: Data(json.utf8))
        XCTAssertEqual(testObject.uuid, uuid)
        XCTAssertEqual(testObject.fullName, fullName)
        XCTAssertNil(testObject.phoneNumber)
        XCTAssertEqual(testObject.emailAddress, emailAddress)
        XCTAssertEqual(testObject.biography, biography)
        XCTAssertEqual(testObject.photoSmall, photoSmall)
        XCTAssertEqual(testObject.photoLarge, photoLarge)
        XCTAssertEqual(testObject.team, team)
        XCTAssertEqual(testObject.classification, classification)
    }

    func testDecodableWithoutBiography() throws {
        let json = """
        {
        "uuid" : "\(uuid.uuidString)",
        "full_name" : "\(fullName ?? "")",
        "phone_number" : "\(phoneNumber ?? "")",
        "email_address" : "\(emailAddress ?? "")",
        "photo_url_small" : "\(photoSmall.absoluteString)",
        "photo_url_large" : "\(photoLarge.absoluteString)",
        "team" : "\(team ?? "")",
        "employee_type" : "\(classification?.rawValue ?? "")"
        }
        """
        let testObject: Employee = try decoder.decode(Employee.self, from: Data(json.utf8))
        XCTAssertEqual(testObject.uuid, uuid)
        XCTAssertEqual(testObject.fullName, fullName)
        XCTAssertEqual(testObject.phoneNumber, phoneNumber)
        XCTAssertEqual(testObject.emailAddress, emailAddress)
        XCTAssertNil(testObject.biography)
        XCTAssertEqual(testObject.photoSmall, photoSmall)
        XCTAssertEqual(testObject.photoLarge, photoLarge)
        XCTAssertEqual(testObject.team, team)
        XCTAssertEqual(testObject.classification, classification)
    }

    func testDecodableWithoutSmallPhoto() throws {
        let json = """
        {
        "uuid" : "\(uuid.uuidString)",
        "full_name" : "\(fullName ?? "")",
        "phone_number" : "\(phoneNumber ?? "")",
        "email_address" : "\(emailAddress ?? "")",
        "biography" : "\(biography ?? "")",
        "photo_url_large" : "\(photoLarge.absoluteString)",
        "team" : "\(team ?? "")",
        "employee_type" : "\(classification?.rawValue ?? "")"
        }
        """
        let testObject: Employee = try decoder.decode(Employee.self, from: Data(json.utf8))
        XCTAssertEqual(testObject.uuid, uuid)
        XCTAssertEqual(testObject.fullName, fullName)
        XCTAssertEqual(testObject.phoneNumber, phoneNumber)
        XCTAssertEqual(testObject.emailAddress, emailAddress)
        XCTAssertEqual(testObject.biography, biography)
        XCTAssertNil(testObject.photoSmall)
        XCTAssertEqual(testObject.photoLarge, photoLarge)
        XCTAssertEqual(testObject.team, team)
        XCTAssertEqual(testObject.classification, classification)
    }

    func testDecodableWithoutLargePhoto() throws {
        let json = """
        {
        "uuid" : "\(uuid.uuidString)",
        "full_name" : "\(fullName ?? "")",
        "phone_number" : "\(phoneNumber ?? "")",
        "email_address" : "\(emailAddress ?? "")",
        "biography" : "\(biography ?? "")",
        "photo_url_small" : "\(photoSmall.absoluteString)",
        "team" : "\(team ?? "")",
        "employee_type" : "\(classification?.rawValue ?? "")"
        }
        """
        let testObject: Employee = try decoder.decode(Employee.self, from: Data(json.utf8))
        XCTAssertEqual(testObject.uuid, uuid)
        XCTAssertEqual(testObject.fullName, fullName)
        XCTAssertEqual(testObject.phoneNumber, phoneNumber)
        XCTAssertEqual(testObject.emailAddress, emailAddress)
        XCTAssertEqual(testObject.biography, biography)
        XCTAssertEqual(testObject.photoSmall, photoSmall)
        XCTAssertNil(testObject.photoLarge)
        XCTAssertEqual(testObject.team, team)
        XCTAssertEqual(testObject.classification, classification)
    }
}
