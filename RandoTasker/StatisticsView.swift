//
//  Stats.swift
//  RandoTasker
//
//  Created by Abhinav Rathod on 2/16/22.
//

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var taskList: TaskList
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(
        entity: TaskStatistics.entity(),
        sortDescriptors:
            [NSSortDescriptor(keyPath: \TaskStatistics.value, ascending: true)]
    ) var stTasks: FetchedResults<TaskStatistics>
    
    var body: some View {
        NavigationView {
            VStack {
                CustomText("Task Statistics").font(.system(size: 30, weight: .bold, design: .rounded))
                List {
                    ForEach(stTasks, id:\.self) { task in
                        NavigationLink(destination: TaskDetailView(taskStatistic: task)) {
                            TaskRowView(taskText: task.value!, consecutive: task.consecutive, total: task.total)
                        }
                    }
                }
            }
            .listStyle(.grouped)
        }
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView().environmentObject(TaskList())
    }
}
