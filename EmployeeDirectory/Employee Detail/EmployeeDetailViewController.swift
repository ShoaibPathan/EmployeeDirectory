//
//  EmployeeDetailViewController.swift
//  EmployeeDirectory
//
//  Created by Patrick Maltagliati on 9/25/20.
//  Copyright © 2020 Patrick Maltagliati. All rights reserved.
//

import CoreData
import SwiftUI
import UIKit

class EmployeeDetailViewController: UIViewController {
    private let dataStack: DataStackProtocol
    private let id: UUID

    init(dataStack: DataStackProtocol, selectedEmployeeId: UUID) {
        self.dataStack = dataStack
        id = selectedEmployeeId
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let request: NSFetchRequest<EmployeeMO> = EmployeeMO.fetchRequest()
        request.predicate = NSPredicate(format: "uuid == %@", id.uuidString)
        dataStack.persistentContainer.performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            do {
                let result = try context.fetch(request)
                if let employeeMO = result.first, let employee = Employee(employeeMO) {
                    DispatchQueue.main.async {
                        let hostViewController = UIHostingController(rootView: EmployeeDetailView(employee: employee))
                        self.add(hostViewController)
                        hostViewController.pinToEdges(of: self.view)
                    }
                }
            } catch {
                print("error: \(error.localizedDescription)")
            }
        }
    }
}
