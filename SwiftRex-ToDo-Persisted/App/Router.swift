//
//  Router.swift
//  SwiftRex-ToDo-Persisted
//
//  Created by Adrian Ward on 12/10/2020.
//

import Foundation

import SwiftRex


struct Router {
    /// This is the entrypoint for the Application.
    /// Note : this seems a little redundant since we could have directly called the ViewProducer for TaskList.
    ///        There mighte be a reason... :)
    /// - Parameter store: the application store
    /// - Returns: the first view for the application (TaskList)
    static func taskListView<S: StoreType>(store: S) -> TaskList where S.ActionType == AppAction, S.StateType == AppState {
        ViewProducers.taskList(store: store).view()
    }
    
}
