//
//  AddTaskView.swift
//  RandoTasker
//
//  Created by Abhinav Rathod on 2/21/22.
//

import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject var taskList: TaskList
    @State private var newTask = ""
    @State private var isShowing = false
    @State private var duplicate = false
    
    var body: some View {
        VStack {
            TextField("New Task..", text: $newTask)
                .onChange(of: newTask, perform: { newValue in
                    if taskList.items.contains(where: { tl in
                        tl.value.uppercased() == newTask.uppercased()
                    }) {
                        duplicate = true
                    } else {
                        duplicate = false
                    }
                })
                .foregroundColor(duplicate ? .red : .green)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .border(.brown)
                .textFieldStyle(.roundedBorder)
                .padding()
            Button {
                isShowing = true
                if newTask.isEmpty {
                    isShowing = false
                }
            } label: {
                Text("Add")
                    .frame(maxWidth: 300, maxHeight: 50)
            }
            .buttonStyle(CustomButtonStyle())
            .disabled(duplicate ? true : false)
            .alert("Adding task '\(newTask)'", isPresented: $isShowing) {
                Button("OK") {
                    isShowing = false
                    var taskListBool = [TaskItem]()
                    for i in taskList.items {
                        taskListBool.append(TaskItem(id: UUID(), value: i.value, selected: "false"))
                    }
                    let id = UUID()
                    if !taskList.items.contains(where: { tl in
                        tl.value.uppercased() == newTask.uppercased()
                    }) {
                        taskList.add(item: TaskItemLocal(id: id, value: newTask, selected: false))
                    }
                    if !taskListBool.contains(where: { tlb in
                        tlb.value.uppercased() == newTask.uppercased()
                    }) {
                        taskListBool.append(TaskItem(id: id, value: newTask, selected: "false"))
                    }
                    Bundle.main.writeJSON(taskListBool, to: "tasks.json")
                    newTask = ""
                }
                Button {
                    isShowing = false
                } label: {
                    Text("Cancel")
                        .frame(maxWidth: 300, maxHeight: 50)
                }
                .buttonStyle(CustomButtonStyle())
            }
            .foregroundColor(Constants.color)
        }
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView().environmentObject(TaskList())
    }
}
