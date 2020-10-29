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
    typealias Task = TaskDTO
    
    @ObservedObject var viewModel: ObservableViewModel<ViewAction, ViewState>
    @State private var editMode = EditMode.inactive
    @State private var taskName = ""
    var rowProducer: ViewProducer<TaskDTO, TaskCellView>
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(viewModel.state.tasks) { task in
                        rowProducer.view(task)
                            .onTapGesture(count: 1) {
                                viewModel.state.selected = task.id
                                taskName = task.name
                            }
                    }
                    .onDelete(perform: {
                        viewModel.dispatch(.delete(viewModel.state.tasks[$0.first!].id))
                    })
                    .onMove(perform: { indices, newOffset in
                        viewModel.dispatch(.move(indices, newOffset))
                    })
                }
                
                ConditionalView(editMode == .inactive) { _ in
                    VStack {
                        Spacer()
                        
                        HStack {
                            TextField("New task...", text: $taskName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Spacer()
                            
                            Button(action: {
                                if let editId = viewModel.state.selected
                                {
                                    /// Passing a whole DTO rather than just the name so can add further editable values later 
                                    viewModel.dispatch(.update(editId, TaskDTO(name: taskName)))
                                } else {
                                    let dto = TaskDTO(name: taskName)
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
            .navigationBarItems( trailing: EditButton() )
            .navigationBarTitle(viewModel.state.title)
            .environment(\.editMode, $editMode)
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
