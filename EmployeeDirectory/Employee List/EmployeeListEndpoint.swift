//
//  EmployeeListEndpoint.swift
//  EmployeeDirectory
//
//  Created by Patrick Maltagliati on 9/8/20.
//  Copyright © 2020 Patrick Maltagliati. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol EmployeeListEndpointProtocol {
    func load(_ version: EmployeeListEndpoint.Version) -> Single<[Employee]>
}

class EmployeeListEndpoint: EmployeeListEndpointProtocol {
    private let urlSession: URLSession
    private let decoder = JSONDecoder()
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func load(_ version: EmployeeListEndpoint.Version) -> Single<[Employee]> {
        urlSession
            .rx
            .response(request: URLRequest(url: version.url))
            .asSingle()
            .flatMap { [weak self] response in
                let (httpResponse, data) = response
                guard (200...299).contains(httpResponse.statusCode) else {
                    return Single.error(EmployeeListEndpoint.Error.serverError)
                }
                guard let employees = try? self?.decoder.decode([Employee].self, from: data) else {
                    return Single.error(EmployeeListEndpoint.Error.parsingError)
                }
                return Single.just(employees)
        }
    }
}

extension EmployeeListEndpoint {
    enum Version: CaseIterable {
        case success
        case error
        case empty
        
        fileprivate var url: URL {
            switch self {
            case .success:
                return URL(staticString: "https://s3.amazonaws.com/sq-mobile-interview/employees.json")
            case .error:
                return URL(staticString: "https://s3.amazonaws.com/sq-mobile-interview/employees_malformed.json")
            case .empty:
                return URL(staticString: "https://s3.amazonaws.com/sq-mobile-interview/employees_empty.json")
            }
        }
    }
    
    enum Error: Swift.Error {
        case serverError
        case parsingError
    }
}

private extension URL {
    init(staticString string: StaticString) {
        guard let url = URL(string: "\(string)") else {
            preconditionFailure("Invalid static URL string: \(string)")
        }
        self = url
    }
}
