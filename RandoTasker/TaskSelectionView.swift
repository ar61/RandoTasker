//
//  TaskView.swift
//  RandoTasker
//
//  Created by Abhinav Rathod on 2/15/22.
//

import SwiftUI

struct TaskSelectionView: View {
    @EnvironmentObject var taskList: TaskList
    @EnvironmentObject var currentList: CurrentTaskList
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @Binding var todo: Bool
    @State private var showFailureAlert = false
    
    @FetchRequest(
        entity: TodaysTasks.entity(),
        sortDescriptors:
            [NSSortDescriptor(keyPath: \TodaysTasks.value, ascending: true)]
    ) var sTasks: FetchedResults<TodaysTasks>

    @FetchRequest(
        entity: TaskStatistics.entity(),
        sortDescriptors:
            [NSSortDescriptor(keyPath: \TaskStatistics.value, ascending: true)]
    ) var stTasks: FetchedResults<TaskStatistics>
    
    var body: some View {
        NavigationView {
            VStack {
                CustomText("Add your daily grind").font(.system(size: 30, weight: .bold, design: .rounded))
                List {
                    ForEach(taskList.items.indices, id: \.self) { index in
                        Toggle(isOn: $taskList.items[index].selected) {
                            Image(systemName: "circle.inset.filled")
                                .foregroundColor(Constants.color)
                            CustomText(taskList.items[index].value)
                        }
                        .onChange(of: taskList.items[index].selected) { s in
                            if !s {
                                if let idx = currentList.items.firstIndex(where: { ct in
                                    ct.value == taskList.items[index].value
                                }) {
                                    currentList.items.remove(at: idx)
                                }
                                return
                            }
                            if !sTasks.contains(where: { t in
                                t.value == taskList.items[index].value
                            }) {
                                addTodaysTasks(task: taskList.items[index])
                            }
                        }
                        .toggleStyle(CheckboxStyle())
                    }
                    .onMove { indexSet, offset in
                        taskList.items.move(fromOffsets: indexSet, toOffset: offset)
                    }
                    .onDelete { indexSet in
                        var taskListBool = [TaskItem]()
                        taskList.items.remove(atOffsets: indexSet)
                        for i in taskList.items {
                            taskListBool.append(TaskItem(id: i.id, value: i.value, selected: i.selected ? "true" : "false"))
                        }
                        Bundle.main.writeJSON(taskListBool, to: "tasks.json")
                    }
                    Section(header: Text("Options")) {
                        NavigationLink(destination: AddTaskView()) {
                            CustomText("Add new")
                        }
                        NavigationLink(destination: StatisticsView()) {
                            CustomText("View Stats")
                        }
                    }
                }
                .listStyle(.grouped)
                Button {
                    if currentList.items.isEmpty {
                        showFailureAlert = true
                    } else {
                        showFailureAlert = false
                        todo = true
                        commitSelectedTasks()
                    }
                } label: {
                    Text("Start your day!")
                        .frame(maxWidth: 300, maxHeight: 50)
                }
                .buttonStyle(CustomButtonStyle())
                .alert(isPresented: $showFailureAlert, content: {
                    Alert(title: Text("Warning")
                        .foregroundColor(Constants.color),
                          message: Text("Please select your todos for today!")
                        .foregroundColor(Constants.color), dismissButton: .default(Text("OK")
                            .foregroundColor(Constants.color), action: {
                        showFailureAlert = false
                            }))
                })
            }
            .toolbar{ EditButton() }
        }
        // Changes Color of whole background
        //.colorInvert()
        //.colorMultiply(Color.black)
    }
    
    func commitSelectedTasks() {
        currentList.sort()
        for i in currentList.items {
            if !stTasks.contains(where: { st in
                st.value == i.value
            }) {
                let item = TaskItemLocal(id: i.id, value: i.value, selected: i.completed)
                addTaskStatistics(task: item)
            }
        }
        try? managedObjectContext.save()
    }
    
    func addTodaysTasks(task: TaskItemLocal) {
        let newTaskToSave = TodaysTasks(context: managedObjectContext)
        newTaskToSave.id = task.id
        newTaskToSave.value = task.value
        currentList.add(item: CurrentTask(id: task.id, value: task.value, enabled: false))
    }
    
    func addTaskStatistics(task: TaskItemLocal) {
        let newTaskStat = TaskStatistics(context: managedObjectContext)
        newTaskStat.id = task.id
        newTaskStat.value = task.value
        newTaskStat.consecutive = 0
        newTaskStat.startdate = Date(timeIntervalSinceNow: 0)
        newTaskStat.total = 0
    }
}

struct TaskView_Previews: PreviewProvider {
    @State private static var previewBool = false
    static var previews: some View {
        TaskSelectionView(todo: $previewBool).environmentObject(TaskList()).environmentObject(CurrentTaskList())
            .colorScheme(.dark)
            
    }
}
