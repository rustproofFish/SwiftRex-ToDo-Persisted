//
//  TaskList.swift
//  SwiftRex-ToDo-Persisted
//
//  Created by Adrian Ward on 12/10/2020.
//

import SwiftUI

import CombineRex
import CombineRextensions
import SwiftRex

// MARK: - UI CODE
struct TaskList: View {    
    @ObservedObject var viewModel: ObservableViewModel<ViewAction, ViewState>
    @State private var isEditing = false
    @State private var selectedTask: String?
    @State private var taskName = ""
    var rowProducer: ViewProducer<Task, TaskCellView>
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    sectionedTasksMatching(predicate: { $0.completed == false }, header: "OUSTANDING")
                    sectionedTasksMatching(predicate: { $0.completed == true }, header: "COMPLETED")
                }
                
                ConditionalView(on: !isEditing) { _ in
                    VStack {
                        Spacer()
                        
                        HStack {
                            TextField("New task...", text: $taskName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Spacer()
                            
                            Button(action: {
                                if let editId = selectedTask
                                {
                                    /// Passing a whole DTO rather than just the name so can add further editable values later 
                                    viewModel.dispatch(.update(editId, Task(name: taskName)))
                                } else {
                                    let dto = Task(name: taskName)
                                    viewModel.dispatch(.add(dto))
                                }
                                taskName.removeAll()
                            }) {
                                Image(systemName: "plus")
                            }
                        }
                        .font(.title2)
                        .padding()
                    }
                }
                
            }
            /// Not using EditButton() here to allow conditional mutation of view state
            .navigationBarItems(
                trailing:
                    Button("Edit") {
                        isEditing.toggle()
                        if isEditing {
                            /// Ensuring that a task can't be edited after it has been deleted when edit mode is active
                            selectedTask = nil
                            taskName = ""
                        }
                    })
            .navigationBarTitle(viewModel.state.title)
            .environment(\.editMode, .constant(isEditing ? EditMode.active : EditMode.inactive)).animation(.spring())
        }
    }
    
    private func sectionedTasksMatching(predicate: (Task) -> Bool, header: String) -> some View {
        Section(header: Text(header)) {
            ForEach(viewModel.state.tasks.filter(predicate)) { task in
                rowProducer.view(task)
                    .onTapGesture(count: 1) {
                        selectedTask = task.id
                        taskName = task.name
                    }
            }
            .onDelete(perform: {
                viewModel.dispatch(.delete(viewModel.state.tasks[$0.first!].id))
                selectedTask = nil
                taskName.removeAll()
            })
            .onMove(perform: { indices, newOffset in
                viewModel.dispatch(.move(indices, newOffset))
            })
        }
    }
}


#if DEBUG
struct TaskList_Previews: PreviewProvider {
    static let stateMock = AppState.mock
    static let mockStore = ObservableViewModel<AppAction, AppState>.mock(
        state: stateMock,
        action: { action, _, state in
            state = Reducer.app.reduce(action, state)
        }
    )
    static var previews: some View {
        Group {
            TaskList(
                viewModel: TaskList.viewModel(
                    store: mockStore.projection(action: AppAction.list, state: \AppState.tasks)
                ),
                rowProducer: ViewProducers.taskCell(store: mockStore)
            )
        }
    }
}
#endif
