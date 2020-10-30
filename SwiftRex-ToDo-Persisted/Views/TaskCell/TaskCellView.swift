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
    @ObservedObject var viewModel: ObservableViewModel<Action, ViewState>
    
    var body: some View {
        HStack {
            HStack {
                Text(viewModel.state.name)
                Spacer()
            }
            .contentShape(Rectangle())
            /// Spacer and .contentShape required to allow tapGesture on entire cell, not just the text frame
            
            Group {
                viewModel.state.completed ? Image(systemName: "circle.fill") : Image(systemName: "circle")
            }
                .onTapGesture { /// this tap gesture recogniser seems to happily override the recogniser in the parent view - a bit surprised by this...
                    viewModel.dispatch(.toggle(viewModel.state.id))
                }
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

