//
//  ViewFactory.swift
//  SwiftRex-ToDo-Persisted
//
//  Created by Adrian Ward on 12/10/2020.
//

import Foundation

import CombineRextensions
import SwiftRex


struct ViewProducers {
    /// Will produce a TaskList with the appropriate Store projection and the given producer for the rows of the list.
    /// - Parameter store: the application store
    /// - Returns: a TaskList view configured with the appropriate Store projection and row view producer.
    static func taskList<S: StoreType>(store: S) -> ViewProducer<Void, TaskList> where S.StateType == AppState, S.ActionType == AppAction {
        ViewProducer {
            TaskList(
                viewModel: TaskList.viewModel(store: store.projection(
                                                action: AppAction.list,
                                                state: \AppState.tasks)),
                rowProducer: taskCell(store: store)
            )
        }
    }
    
    /// Will produce a TaskCellView with the appropriate Store projection for a given task identifier
    /// - Parameter store: the application store
    /// - Returns: a CheckmarkView view configured with the appropriate Stoore projection.
    static func taskCell<S: StoreType>(store: S) -> ViewProducer<Task, TaskCellView> where S.StateType == AppState, S.ActionType == AppAction {
        ViewProducer { task in
            TaskCellView(
                viewModel: TaskCellView.viewModel(store: store.projection(
                                                    action: AppAction.task,
                                                    state: \AppState.tasks),
                                                  taskId: task.id)
            )
        }
    }
}
