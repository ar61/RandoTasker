//
//  RandoTaskerApp.swift
//  RandoTasker
//
//  Created by Abhinav Rathod on 2/15/22.
//

import SwiftUI
import CoreData

@main
struct RandoTaskerApp: App {
    @StateObject var taskList = TaskList()
    @StateObject var currentList = CurrentTaskList()
    let persistenceController = PersistenceController.shared
    @Environment(\.scenePhase) var scenePhase
    
    init() {
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = Constants.uiColor
    }
    
    var body: some Scene {
        WindowGroup {
            
            StartView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(taskList)
                .environmentObject(currentList)
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
    }
}
