//
//  URLProtocolMock.swift
//  EmployeeDirectoryTests
//
//  Created by Patrick Maltagliati on 9/8/20.
//  Copyright © 2020 Patrick Maltagliati. All rights reserved.
//

import Foundation
import XCTest

class URLProtocolMock: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
    static weak var testCase: XCTestCase?
    
    override class func canInit(with request: URLRequest) -> Bool { true }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    
    override func startLoading() {
        guard let requestHandler = URLProtocolMock.requestHandler else {
            URLProtocolMock.testCase?.recordFailure(withDescription: "No request handler",
                                                    inFile: #file,
                                                    atLine: #line,
                                                    expected: false)
            return
        }
        do {
            let (response, data) = try requestHandler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}
