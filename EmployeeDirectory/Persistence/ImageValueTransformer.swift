//
//  ImageValueTransformer.swift
//  EmployeeDirectory
//
//  Created by Patrick Maltagliati on 9/17/20.
//  Copyright © 2020 Patrick Maltagliati. All rights reserved.
//

import UIKit

@objc(UIImageValueTransformer)
final class ImageValueTransformer: NSSecureUnarchiveFromDataTransformer {
    static let name = NSValueTransformerName(rawValue: String(describing: ImageValueTransformer.self))

    override static var allowedTopLevelClasses: [AnyClass] {
        return [UIImage.self]
    }

    public static func register() {
        let transformer = ImageValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
