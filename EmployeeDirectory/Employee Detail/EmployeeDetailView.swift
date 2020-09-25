//
//  EmployeeDetailView.swift
//  EmployeeDirectory
//
//  Created by Patrick Maltagliati on 9/25/20.
//  Copyright © 2020 Patrick Maltagliati. All rights reserved.
//

import RxSwift
import SwiftUI

struct EmployeeDetailView: View {
    let employee: Employee
    @State var image: UIImage = .placeholder
    private let disposeBag = DisposeBag()

    init(employee: Employee) {
        self.employee = employee
    }

    var body: some View {
        VStack {
            Image(uiImage: image).resizable().aspectRatio(contentMode: .fill).frame(width: 100, height: 100, alignment: .center).clipShape(Circle())
            Item(title: "Email", text: employee.emailAddress)
            Item(title: "Team", text: employee.team)
            Item(title: "Type", text: employee.classification.rawValue)
        }
        .navigationBarTitle(employee.emailAddress)
        .onAppear {
            let url: URL?
            if let optional = self.employee.photoLarge {
                url = optional
            } else if let optional = self.employee.photoSmall {
                url = optional
            } else {
                url = nil
            }

            if let url = url {
                ImageDownloader().download(url: url).observeOn(MainScheduler.instance).subscribe(onSuccess: { image in
                    self.image = image
                }, onError: nil).disposed(by: self.disposeBag)
            }
        }
    }
}

private extension EmployeeDetailView {
    struct Item: View {
        let title: String
        let text: String
        var body: some View {
            HStack {
                Text(verbatim: title)
                Spacer()
                Text(verbatim: text)
            }
        }
    }
}
