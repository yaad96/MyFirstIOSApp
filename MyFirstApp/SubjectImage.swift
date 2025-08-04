//
//  SubjectImage.swift
//  MyFirstApp
//
//  Created by Mainul Hossain on 8/4/25.
//


import Foundation
import SwiftData

@Model
class SubjectImage: Identifiable {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var data: Data

    init(data: Data, timestamp: Date = .now, id: UUID = .init()) {
        self.id = id
        self.data = data
        self.timestamp = timestamp
    }
}
