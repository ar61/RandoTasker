//
//  PersistenceController.swift
//  RandoTasker
//
//  Created by Abhinav Rathod on 2/18/22.
//

import CoreData

struct PersistenceController {
    // A singleton for our entire app to use
    static let shared = PersistenceController()
    // Storage for Core Data
    let container: NSPersistentContainer
    // A test configuration for SwiftUI previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let task = TodaysTasks(context: controller.container.viewContext)
        task.id = UUID()
        task.value = "Draw a picture"
        let taskStat = TaskStatistics(context: controller.container.viewContext)
        taskStat.id = UUID()
        taskStat.total = 0
        taskStat.startdate = Date()
        taskStat.consecutive = 0
        taskStat.value = "Draw a picture"
        let category = Categories(context: controller.container.viewContext)
        category.name = "Uncategorized"
        return controller
    }()
    // An initializer to load Core Data, optionally able
    // to use an in-memory store.
    init(inMemory: Bool = false) {
        // If you didn't name your model Main you'll need
        // to change this name below.
        container = NSPersistentContainer(name: "Main")
        if inMemory {
            container.persistentStoreDescriptions.first?.url =
            URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError("Unable to save")
            }
        }
    }
}
