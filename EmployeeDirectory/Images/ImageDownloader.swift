//
//  ImageDownloader.swift
//  EmployeeDirectory
//
//  Created by Patrick Maltagliati on 9/9/20.
//  Copyright © 2020 Patrick Maltagliati. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol ImageDownloaderProtocol {
    func download(url: URL) -> Single<UIImage>
}

class ImageDownloader: ImageDownloaderProtocol {
    private let urlSession: URLSession

    init(urlSession: URLSession = URLSession(configuration: .ephemeral)) {
        self.urlSession = urlSession
    }

    func download(url: URL) -> Single<UIImage> {
        urlSession
            .rx
            .response(request: URLRequest(url: url))
            .asSingle()
            .flatMap { response in
                let (httpResponse, data) = response
                guard (200 ... 299).contains(httpResponse.statusCode) else {
                    return Single.error(EmployeeListEndpoint.Error.serverError)
                }
                guard let image = UIImage(data: data) else {
                    return Single.error(ImageDownloader.Error.badData)
                }
                return Single.just(image)
            }
    }
}

extension ImageDownloader {
    public enum Error: Swift.Error {
        case badData
    }
}
