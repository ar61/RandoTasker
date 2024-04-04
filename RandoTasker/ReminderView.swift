//
//  ReminderView.swift
//  RandoTasker
//
//  Created by Abhinav Rathod on 3/4/22.
//

import SwiftUI
import EventKit

struct ReminderView: View {
    
    let store = EKEventStore()
    
    /*init() {
        askForPermission {
            
        }
    }*/
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        // Reminders - Setup tasks with toggle and add reminders with time
        // Add/Edit/Delete Reminders with EKReminder class
    }
    
    func askForPermission(grantedAction: @escaping () -> Void) {
        store.requestAccess(to: .reminder) { (granted, error) in
            if let error = error {
                print(error)
                return
            }
            
            if granted {
                grantedAction()
            }
        }
    }
}

struct ReminderView_Previews: PreviewProvider {
    static var previews: some View {
        ReminderView()
    }
}
