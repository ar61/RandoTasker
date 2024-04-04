//
//  Tasks.swift
//  RandoTasker
//
//  Created by Abhinav Rathod on 2/15/22.
//

import SwiftUI
import Combine

struct TaskItem: Codable, Equatable, Identifiable, Hashable {
    var id: UUID
    var value: String
    var selected: String
}

struct TaskItemLocal: Codable, Equatable, Identifiable, Hashable {
    var id: UUID
    var value: String
    var selected: Bool
}

struct CurrentTask: Equatable, Identifiable, Hashable {
    static func == (lhs: CurrentTask, rhs: CurrentTask) -> Bool {
        lhs.value == rhs.value
    }
    
    var id: UUID
    var value: String
    var iconName: String
    var completed: Bool
    init(id: UUID,value: String, enabled enabledValue: Bool) {
        self.id = id
        self.value = value
        self.iconName = "xmark"
        self.completed = enabledValue
    }
}

struct EndTime: Hashable {
    var date: Int
    var month: Int
    var hour: Int
    var mins: Int
}
