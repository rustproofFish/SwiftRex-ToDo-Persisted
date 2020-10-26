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
        case update(String)
    }
    
    // MARK: - STATE
    #warning("Ensure that State is not used within SwiftUI views - causes a namespace collision with @State")
    struct ViewState: Equatable {
        let index: Int
        let name: String
        
        static var empty = ViewState(index: 0, name: "")
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
            index: state.index,
            name: state.name
        )
    }
}
