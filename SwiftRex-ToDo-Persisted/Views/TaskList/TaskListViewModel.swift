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
        case add(TaskDTO)
        case delete(String)
        case move(IndexSet, Int)
        case select(IndexSet)
        case update(String, TaskDTO)
    }
    
    // MARK: - STATE
    struct ViewState: Equatable {
        var title: String
        var tasks: [Task]
        var selected: String?
        
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
        case let .move(index, offset): return .move(index, offset)
        case let .select(index): return .select(index)
        case let .update(id, task): return .update(id, task)
        }
    }
    
    private static func transform(from state: [TaskDTO]) -> TaskList.ViewState {
        TaskList.ViewState(
            title: "Tasks",
            tasks: state,
            selected: nil
        )
    }
}
