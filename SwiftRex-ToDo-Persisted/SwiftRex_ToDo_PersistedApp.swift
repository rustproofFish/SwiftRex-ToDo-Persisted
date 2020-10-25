//
//  SwiftRex_ToDo_PersistedApp.swift
//  SwiftRex-ToDo-Persisted
//
//  Created by Adrian Ward on 25/10/2020.
//

import SwiftUI
import CombineRex


@main
struct SwiftRex_ToDoList_PersistedApp: App {
    @StateObject var store = World
        .origin
        .store()
        .asObservableViewModel(initialState: .empty)

    var body: some Scene {
        WindowGroup {
            Router.taskListView(store: store)
        }
    }
}
