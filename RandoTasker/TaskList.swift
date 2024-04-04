//
//  TaskList.swift
//  RandoTasker
//
//  Created by Abhinav Rathod on 2/15/22.
//

import SwiftUI

class TaskList: ObservableObject {
    
    @Published var items = [TaskItemLocal]()
    
    var total: Int {
        return items.count
    }
    
    func add(item: TaskItemLocal) {
        items.append(item)
    }
    
    func remove(item: TaskItemLocal) {
        if let idx = items.firstIndex(of: item) {
            items.remove(at: idx)
        }
    }
    
    func sort() {
        items.sort { return String.StandardComparator(.lexical).compare($0.value, $1.value) == .orderedAscending }
    }
}

class CurrentTaskList: ObservableObject {
    
    @Published var items = [CurrentTask]()
    
    var total: Int {
        return items.count
    }
    
    func add(item: CurrentTask) {
        items.append(item)
    }
    
    func remove(item: CurrentTask) {
        if let idx = items.firstIndex(of: item) {
            items.remove(at: idx)
        }
    }
    
    func sort() {
        items.sort { return String.StandardComparator(.lexical).compare($0.value, $1.value) == .orderedAscending }
    }
}
