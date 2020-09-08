//
//  EmployeeListEndpointTests.swift
//  EmployeeDirectoryTests
//
//  Created by Patrick Maltagliati on 9/8/20.
//  Copyright © 2020 Patrick Maltagliati. All rights reserved.
//

import XCTest
import RxSwift

class EmployeeListEndpointTests: XCTestCase {
    private var testObject: EmployeeListEndpoint!
    private var encoder: JSONEncoder!
    private var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [URLProtocolMock.self]
        let urlSession = URLSession(configuration: configuration)
        testObject = EmployeeListEndpoint(urlSession: urlSession)
        URLProtocolMock.testCase = self
        encoder = JSONEncoder()
        disposeBag = DisposeBag()
    }
    
    override func tearDownWithError() throws {
        URLProtocolMock.requestHandler = nil
        URLProtocolMock.testCase = nil
    }
    
    func testSuccess() throws {
        let expectation = self.expectation(description: "endpoint expection")
        let employees = (0...Int.random(in: 3...6)).map { _ in Employee.test }
        let data = try encoder.encode(employees)
        
        URLProtocolMock.requestHandler = { request in
            let requestUrl = try XCTUnwrap(request.url)
            XCTAssertEqual(requestUrl.absoluteString, "https://s3.amazonaws.com/sq-mobile-interview/employees.json")
            let response = HTTPURLResponse(url: requestUrl,
                                           statusCode: Int.random(in: 200...299),
                                           httpVersion: nil,
                                           headerFields: nil)
            let unwrappedResponse = try XCTUnwrap(response)
            return (unwrappedResponse, data)
        }
        
        testObject
            .load(.success)
            .subscribe(
                onSuccess: {  receivedEmployees in
                    XCTAssertEqual(receivedEmployees, employees)
                    expectation.fulfill()
            },
                onError: { _ in
                    XCTFail()
            }
        )
            .disposed(by: disposeBag)
        waitForExpectations(timeout: 1)
    }
    
    func testSuccessCannotBeParsed() throws {
        let expectation = self.expectation(description: "endpoint expection")
        
        URLProtocolMock.requestHandler = { request in
            let requestUrl = try XCTUnwrap(request.url)
            XCTAssertEqual(requestUrl.absoluteString, "https://s3.amazonaws.com/sq-mobile-interview/employees.json")
            let response = HTTPURLResponse(url: requestUrl,
                                           statusCode: Int.random(in: 200...299),
                                           httpVersion: nil,
                                           headerFields: nil)
            let unwrappedResponse = try XCTUnwrap(response)
            return (unwrappedResponse, Data(UUID().uuidString.utf8))
        }
        
        testObject
            .load(.success)
            .subscribe(
                onSuccess: { _ in XCTFail() },
                onError: { _ in expectation.fulfill() }
        )
            .disposed(by: disposeBag)
        waitForExpectations(timeout: 1)
    }
    
    func testSuccessServerError() throws {
        let expectation = self.expectation(description: "endpoint expection")
        let employees = (0...Int.random(in: 3...6)).map { _ in Employee.test }
        let data = try encoder.encode(employees)
        
        URLProtocolMock.requestHandler = { request in
            let requestUrl = try XCTUnwrap(request.url)
            XCTAssertEqual(requestUrl.absoluteString, "https://s3.amazonaws.com/sq-mobile-interview/employees.json")
            let response = HTTPURLResponse(url: requestUrl,
                                           statusCode: Int.random(in: 400...599),
                                           httpVersion: nil,
                                           headerFields: nil)
            let unwrappedResponse = try XCTUnwrap(response)
            return (unwrappedResponse, data)
        }
        
        testObject
            .load(.success)
            .subscribe(
                onSuccess: { _ in XCTFail() },
                onError: { _ in expectation.fulfill() }
        )
            .disposed(by: disposeBag)
        waitForExpectations(timeout: 1)
    }
    
    func testError() throws {
        let expectation = self.expectation(description: "endpoint expection")
        
        URLProtocolMock.requestHandler = { request in
            let requestUrl = try XCTUnwrap(request.url)
            XCTAssertEqual(requestUrl.absoluteString, "https://s3.amazonaws.com/sq-mobile-interview/employees_malformed.json")
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        
        testObject
            .load(.error)
            .subscribe(
                onSuccess: { _ in XCTFail() },
                onError: { _ in expectation.fulfill() }
        )
            .disposed(by: disposeBag)
        waitForExpectations(timeout: 1)
    }
    
    func testEmpty() throws {
        let expectation = self.expectation(description: "endpoint expection")
        let data = try encoder.encode([Employee]())
        
        URLProtocolMock.requestHandler = { request in
            let requestUrl = try XCTUnwrap(request.url)
            XCTAssertEqual(requestUrl.absoluteString, "https://s3.amazonaws.com/sq-mobile-interview/employees_empty.json")
            let response = HTTPURLResponse(url: requestUrl,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)
            let unwrappedResponse = try XCTUnwrap(response)
            return (unwrappedResponse, data)
        }
        
        testObject
            .load(.empty)
            .subscribe(
                onSuccess: {  receivedEmployees in
                    XCTAssertTrue(receivedEmployees.isEmpty)
                    expectation.fulfill()
            },
                onError: { _ in
                    XCTFail()
            }
        )
            .disposed(by: disposeBag)
        waitForExpectations(timeout: 1)
    }
}
