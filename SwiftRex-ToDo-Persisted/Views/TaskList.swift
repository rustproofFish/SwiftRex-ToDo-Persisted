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


extension TaskList {
    // MARK: - ACTIONS
    /// Needed to prefix 'View' to both Action and State otherwise collission with SwiftUI's @State...
    enum ViewAction {
        case add(TaskObject.DTO)
        case delete(String)
        case move(IndexSet, Int)
        case appear
    }
    
    // MARK: - STATE
    struct ViewState: Equatable {
        var title: String
        var tasks: [Task]
        
        static var empty = ViewState(title: "Tasks", tasks: [])
    }
}

extension TaskList {
    static func viewModel<S: StoreType>(store: S) -> ObservableViewModel<TaskList.ViewAction, TaskList.ViewState>
    where S.ActionType == ListAction, S.StateType == [Task] {
        store
            .projection(action: Self.transform, state: Self.transform)
            .asObservableViewModel(initialState: .empty)
    }
    
    private static func transform(_ viewAction: TaskList.ViewAction) -> ListAction? {
        switch viewAction {
        case let .add(task): return .add(task)
        case let .delete(id): return .delete(id)
        case let .move(offset, index): return .move(offset, index)
        case .appear: return .appear
        }
    }
    
    private static func transform(from state: [TaskObject.DTO]) -> TaskList.ViewState {
        TaskList.ViewState(
            title: "Tasks",
            tasks: state
        )
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
