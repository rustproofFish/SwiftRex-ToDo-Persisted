//
//  TaskCellView.swift
//  SwiftRex-ToDo-Persisted
//
//  Created by Adrian Ward on 12/10/2020.
//

import SwiftUI

import CombineRex
import CombineRextensions
import SwiftRex


struct TaskCellView: View {
    typealias Task = TaskObject.DTO
    @ObservedObject var viewModel: ObservableViewModel<Action, State>
    
    var body: some View {
        HStack {
            Text("\(viewModel.state.index)")
            TextField("Enter task here...", text: viewModel.binding[\.name] { Action.update($0) })
                .disabled(true)
        }
    }
}

// MARK: - VIEWMODEL
extension TaskCellView {
    // MARK: - ACTIONS
    enum Action {
        case update(String)
    }
    
    // MARK: - STATE
    struct State: Equatable {
        let index: Int
        let name: String
        
        static var empty = State(index: 0, name: "")
    }
}

extension TaskCellView {
    static func viewModel<S: StoreType>(store: S, taskId: String) -> ObservableViewModel<TaskCellView.Action, TaskCellView.State>
    where S.ActionType == TaskAction, S.StateType == [Task] {
        let task = store.mapState { state in state.first { $0.id == taskId } }
        return task
            .projection(action: Self.transform(taskId: taskId), state: Self.transform)
            .asObservableViewModel(initialState: .empty)
    }
    
    static func transform(taskId: String) -> (TaskCellView.Action) -> TaskAction? {
        return { viewAction in
            switch viewAction {
            case let .update(title): return .update(taskId, title)
            }
        }
    }
    
    static func transform(from state: Task?) -> TaskCellView.State {
        guard let state = state else { return TaskCellView.State.empty }
        return TaskCellView.State(
            index: state.index,
            name: state.name
        )
    }
}

//
//struct TaskCellView_Previews: PreviewProvider {
//    static var previews: some View {
//        TaskCellView()
//    }
//}

struct TaskCellView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
