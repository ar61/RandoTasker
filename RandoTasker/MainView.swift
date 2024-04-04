//
//  MainView.swift
//  RandoTasker
//
//  Created by Abhinav Rathod on 2/15/22.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var taskList: TaskList
    @EnvironmentObject var currentList: CurrentTaskList
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @Binding var todo: Bool
    
    @FetchRequest(
        entity: TodaysTasks.entity(),
        sortDescriptors:
            [NSSortDescriptor(keyPath: \TodaysTasks.value, ascending: true)]
    ) var sTasks: FetchedResults<TodaysTasks>
    
    var body: some View {
        VStack{
            TabView {
                TodoView(todo: $todo)
                    .tabItem {
                        Label("Tasks", systemImage: "list.dash")
                    }
                    .tag(1)
                StatisticsView()
                    .tabItem {
                        Label("Stats", systemImage: "chart.line.uptrend.xyaxis")
                    }
                    .tag(2)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    @State private static var todo = false
    static var previews: some View {
        MainView(todo: $todo).environmentObject(TaskList()).environmentObject(CurrentTaskList())
    }
}
