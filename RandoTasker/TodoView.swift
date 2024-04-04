//
//  ContentView.swift
//  RandoTasker
//
//  Created by Abhinav Rathod on 2/15/22.
//

import SwiftUI

struct TodoView: View {
    @EnvironmentObject var taskList: TaskList
    @EnvironmentObject var currentList: CurrentTaskList
    @Binding var todo: Bool
    
    @State private var alertIdentifier = AlertIdentifier(id: .error)
    @State private var showAlert = false
    @Environment(\.managedObjectContext) var managedObjectContext
    
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
    
    @FetchRequest(
        entity: TemporaryTodoDone.entity(),
        sortDescriptors:
            [NSSortDescriptor(keyPath: \TemporaryTodoDone.value, ascending: true)]
    ) var tempTasks: FetchedResults<TemporaryTodoDone>
    
    var body: some View {
        NavigationView {
            VStack {
                CustomText("Todays Todo:").font(.system(size: 30, weight: .bold, design: .rounded))
                List {
                    ForEach(currentList.items.indices, id:\.self) { index in
                        Toggle(isOn: $currentList.items[index].completed, label: {
                            Image(systemName: "bookmark.fill")
                                .foregroundColor(Constants.color)
                            CustomText(currentList.items[index].value)
                        })
                            .toggleStyle(CheckboxStyle())
                            .onChange(of: currentList.items[index].completed) { s in
                                if !s {
                                    return
                                }
                                updateTempTodos(currentList.items[index].value)
                                updateTaskCompletionStatus(currentList.items[index].value)
                                try? managedObjectContext.save()
                            }
                    }
                    .onMove { indexSet, offset in
                        currentList.items.move(fromOffsets: indexSet, toOffset: offset)
                    }
                    .onDelete { indexSet in
                        currentList.items.remove(atOffsets: indexSet)
                    }
                }
                Button {
                    for i in currentList.items {
                        if !i.completed {
                            alertIdentifier.id = .error
                            showAlert = true
                            return
                        }
                    }
                    alertIdentifier.id = .success
                    showAlert = true
                } label: {
                    Text("Finish for the day")
                        .frame(maxWidth: 300, maxHeight: 50)
                }
                .disabled(currentList.items.isEmpty)
                .alert(isPresented: $showAlert, content: {
                    switch self.alertIdentifier.id {
                        case .error:
                            return Alert(title: Text("Some tasks not done yet!"), message: Text("Are you sure?"), primaryButton: .default(Text("Continue Anyway")) {
                                    finishUpTodo()
                                }, secondaryButton: .cancel(Text("No")))
                        case .success:
                            return Alert(title: Text("Kudos!"), message: Text("Congratulations! You did it!"), dismissButton: .default(Text("Yay")) {
                                    finishUpTodo()
                                })
                    }
                })
                .buttonStyle(CustomButtonStyle())
            }
        }
    }
    
    func finishUpTodo() {
        resetCompletedTasksInSelectionView()
        updateCompletedTasksInStatistics()
        clearTempTodo()
        clearTodaysTasks()
        try? managedObjectContext.save()
        todo = false
        alertIdentifier.id = .success
        showAlert = true
    }
    
    func updateCompletedTasksInStatistics() {
        for i in currentList.items {
            if i.completed {
                updateTaskStatistics(i.value)
            }
        }
        currentList.items.removeAll()
    }
    
    func clearTodaysTasks() {
        for i in sTasks {
            managedObjectContext.delete(i)
        }
    }
    
    func clearTempTodo() {
        for i in tempTasks {
            managedObjectContext.delete(i)
        }
    }
    
    func resetCompletedTasksInSelectionView() {
        for i in currentList.items {
            if let idx = taskList.items.firstIndex(where: { til in
                til.value == i.value
            }) {
                self.taskList.items[idx].selected = false
                if let fetchedTask = sTasks.first ( where: { tt in
                    tt.value == i.value
                }) {
                    fetchedTask.completed = false
                }
            }
        }
    }
    
    func addNewTime(collection: String, time: String) -> String {
        var newCollection = String()
        let pipechars = collection.filter({ ch in
            ch == "|"
        })
        if pipechars.count == 29 {
            let i = collection.firstIndex(of: "|")
            let idx = String.Index(utf16Offset: (i?.utf16Offset(in: collection))! + 1, in: collection)
            let removedFirstTime = collection[idx...]
            newCollection = removedFirstTime + "|" + time
        } else {
            newCollection = collection + "|" + time
        }
        return newCollection
    }
    
    fileprivate func updateTempTodos(_ value: String) {
        if let fetchedTask = tempTasks.first(where: { tt in
            tt.value == value
        }) {
            fetchedTask.timestamp = grabTaskFinishTime()
            return
        }
        let fetchedTask = TemporaryTodoDone(context: managedObjectContext)
        fetchedTask.value = value
        fetchedTask.timestamp = grabTaskFinishTime()
    }
    
    func grabTaskFinishTime() -> String {
        let df = DateFormatter()
        df.dateFormat = "MM/dd,HH:mm"
        return df.string(from: Date())
    }
    
    fileprivate func getTimeForTask(_ value: String) -> String {
        if let fetchedTask = tempTasks.first(where: { tt in
            tt.value == value
        }) {
            return fetchedTask.timestamp!
        }
        return ""
    }
    
    fileprivate func updateTaskCompletionStatus(_ value: String) {
        guard let fetchedTask = sTasks.first ( where: { tt in
            tt.value == value
        }) else {
            return
        }
        fetchedTask.completed = true
    }
    
    fileprivate func updateTaskStatistics(_ value: String) {
        guard let fetchedTask = stTasks.first ( where: { tt in
            tt.value == value
        }) else {
            return
        }
        let todaysDate = Date(timeIntervalSinceNow: 0)
        let diff = todaysDate.timeIntervalSince(fetchedTask.startdate!)
        if diff < 2*24*60*60 {
            fetchedTask.consecutive = fetchedTask.consecutive + 1
        } else {
            fetchedTask.consecutive = 1
        }
        fetchedTask.total = fetchedTask.total + 1
        var time24 = getTimeForTask(value)
        if time24.isEmpty {
            time24 = grabTaskFinishTime()
        }
        if let str = fetchedTask.endHrfor30Days {
            fetchedTask.endHrfor30Days = addNewTime(collection: str, time: time24)
        } else {
            fetchedTask.endHrfor30Days = time24
        }
    }
}

struct AlertIdentifier {
    enum AlertType {
        case error, success
    }
    var id: AlertType
}

struct ContentView_Previews: PreviewProvider {
    @State private static var todo = false
    static var previews: some View {
        TodoView(todo: $todo).environmentObject(TaskList()).environmentObject(CurrentTaskList())
    }
}

