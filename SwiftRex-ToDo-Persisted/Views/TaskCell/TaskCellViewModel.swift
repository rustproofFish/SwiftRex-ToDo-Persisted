//
//  TaskCellViewModel.swift
//  SwiftRex-ToDo-Persisted
//
//  Created by Adrian Ward on 26/10/2020.
//

import SwiftRex
import CombineRex
import CombineRextensions


extension TaskCellView {
    // MARK: - ACTIONS
    enum Action {
        case update(String) /// user updated Task itle
    }
    
    // MARK: - STATE
    // WARN: - SwiftRex demo code uses State and Action structs but this causes a collision with SwiftUI's @State property wrapper.
    struct ViewState: Equatable {
        let id: String
        let index: Int
        let name: String
        
        static var empty = ViewState(id: "", index: 0, name: "")
    }
    
    // MARK: - VIEW MODEL
    static func viewModel<S: StoreType>(store: S, taskId: String) -> ObservableViewModel<TaskCellView.Action, TaskCellView.ViewState>
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
    
    static func transform(from state: Task?) -> TaskCellView.ViewState {
        guard let state = state else { return TaskCellView.ViewState.empty }
        return TaskCellView.ViewState(
            id: state.id,
            index: state.index,
            name: state.name
        )
    }
}
