//
//  StartView.swift
//  RandoTasker
//
//  Created by Abhinav Rathod on 2/28/22.
//

import SwiftUI

struct StartView: View {
    
    @EnvironmentObject var taskList: TaskList
    @EnvironmentObject var currentList: CurrentTaskList
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) private var colorScheme
    
    @State var todo = false
    
    @FetchRequest(sortDescriptors: [])
    private var sTasks: FetchedResults<TodaysTasks>
    
    var body: some View {
        return Group {
            VStack {
                if todo {
                    MainView(todo: $todo).environmentObject(taskList)
                        .environmentObject(currentList)
                } else {
                    TaskSelectionView(todo: $todo).environmentObject(taskList)
                        .environmentObject(currentList)
                }
            }.onAppear {
                populateList()
                if !self.currentList.items.isEmpty {
                    todo = true
                }
            }
            .preferredColorScheme(.dark)
        }
    }
    
    func populateList() {
        for s in self.sTasks {
            self.currentList.add(item: CurrentTask(id: s.id!, value: s.value!, enabled: s.completed))
        }
        currentList.sort()
        
        let tasks = Bundle.main.decode([TaskItem].self, from: "tasks.json")
        for i in tasks {
            self.taskList.add(item: TaskItemLocal(id: UUID(), value: i.value, selected: i.selected == "false" ? false: true ) )
        }
        self.taskList.sort()
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView().environmentObject(TaskList()).environmentObject(CurrentTaskList())
    }
}
