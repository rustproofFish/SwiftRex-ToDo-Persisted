//
//  TaskListViewModel.swift
//  SwiftRex-ToDo-Persisted
//
//  Created by Adrian Ward on 26/10/2020.
//

import SwiftUI

import SwiftRex
import CombineRex
import CombineRextensions


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
