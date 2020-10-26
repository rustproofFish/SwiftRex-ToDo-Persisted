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
    typealias Task = TaskObject.DTO
    
    @ObservedObject var viewModel: ObservableViewModel<ViewAction, ViewState>
    @State private var editMode = EditMode.inactive
    @State private var taskName = ""
    var rowProducer: ViewProducer<TaskObject.DTO, TaskCellView>
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(viewModel.state.tasks) {
                        rowProducer.view($0)
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
                                let dto = TaskObject.DTO(name: taskName)
                                viewModel.dispatch(.add(dto))
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
