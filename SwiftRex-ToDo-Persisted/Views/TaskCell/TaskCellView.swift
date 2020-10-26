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
    @ObservedObject var viewModel: ObservableViewModel<Action, ViewState>
    
    var body: some View {
        HStack {
            Text(viewModel.state.name)
        }
    }
}


#if DEBUG
struct TaskCellView_Previews: PreviewProvider {
    static let stateMock = AppState.mock
    static let mockStore = ObservableViewModel<AppAction, AppState>.mock(
        state: stateMock,
        action: { action, _, state in
            state = Reducer.app.reduce(action, state)
        }
    )
    static var previews: some View {
        Group {
            // TODO: - Implement preview using mock app state
            Text("Hello World!")
        }
    }
}
#endif
//struct TaskCellView_Previews: PreviewProvider {
//    static var previews: some View {
//        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
//    }
//}
