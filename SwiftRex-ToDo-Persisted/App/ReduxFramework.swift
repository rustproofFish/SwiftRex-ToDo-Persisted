//
//  ReduxFramework.swift
//  SwiftRex-ToDo-Persisted
//
//  Created by Adrian Ward on 09/10/2020.
//

import Foundation

import CombineRex
import SwiftRex
import LoggerMiddleware



//// MARK: - ACTIONS
enum AppAction {
    case appLifecycle(AppLifecycleAction)
    case persistentStore(PersistentStoreAction)
    case list(ListAction)
    case task(TaskAction)
}

enum ListAction {
    case add(TaskDTO)
    case delete(String)
    case move(IndexSet, Int)
    case select(IndexSet)
    case update(String, TaskDTO)
}

enum TaskAction {
    //    case toggle(String)
    case update(String, String)
}


// MARK: - STATE
struct AppState: Equatable {
    typealias Task = TaskDTO
    
    var appLifecycle: AppLifecycle
    var tasks: [Task]
    var taskListState: TaskListState
    
    static var empty: AppState {
        .init(appLifecycle: .backgroundInactive, tasks: [], taskListState: .empty)
    }
    
    static func == (lhs: AppState, rhs: AppState) -> Bool {
        (lhs.appLifecycle == rhs.appLifecycle) && (lhs.tasks == rhs.tasks) && (lhs.taskListState == rhs.taskListState)
    }
    
    static var mock: AppState {
        .init(
            appLifecycle: .backgroundInactive,
            tasks: [
                TaskDTO(name: "Feed chickens"),
                TaskDTO(name: "Walk dog"),
                TaskDTO(name: "Write app"),
                TaskDTO(name: "Wash dishes")
            ],
            taskListState: TaskListState()
        )
    }
}

// MARK: - SUBSTATES
struct TaskListState: Equatable {
    var selectedTask: TaskDTO?
    
    static var empty: TaskListState {
        .init()
    }
}


// MARK: - REDUCERS
extension Reducer where ActionType == AppAction, StateType == AppState {
    static let app =
        Reducer<AppLifecycleAction, AppLifecycle>.lifecycle.lift(
            action: \AppAction.appLifecycle,
            state: \AppState.appLifecycle
        ) <> Reducer<PersistentStoreAction, [TaskDTO]>.persistentStore.lift(
            action: \AppAction.persistentStore,
            state: \AppState.tasks
//        ) <> Reducer<ListAction, [TaskDTO]>.list.lift( // Removed as currently no ListAction Reducer
//            action: \AppAction.list,
//            state: \AppState.tasks
        ) <> Reducer<TaskAction, [TaskDTO]>.task.lift(
            action: \AppAction.task,
            state: \AppState.tasks)
}


//extension Reducer where ActionType == ListAction, StateType == [TaskDTO] {
//    static let list = Reducer { action, state in
//        var state = state
//        switch action {
//        case .appear:
//            // TODO: - Implement additional Logger middleware for debugging
//            print("** VIEW onAppear CALLED **")
//        default:
//            break
//        }
//        return state
//    }
//}

extension Reducer where ActionType == TaskAction, StateType == [TaskDTO] {
    static let task = Reducer { action, state in
        var state = state
        switch action {
        //        case let .toggle(id):
        //            if let index = state.firstIndex(where: { $0.id == id }) {
        //                state[index].completed.toggle()
        //            }
        case let .update(id, name):
            if let index = state.firstIndex(where: { $0.id == id }) {
                state[index].name = name
            }
        }
        return state
    }
}

#warning("How do we ensure the correct State property is being updated? Here we're just searching for any type that is a String and there could e many such properties. Furthermor, why isn't selectedStateId being updated?")

// MARK: - MIDDLEWARE
let appMiddleware =
    IdentityMiddleware<AppAction, AppAction, AppState>().logger()
    <> AppLifecycleMiddleware().lift(
        inputActionMap: { _ in nil },
        outputActionMap: AppAction.appLifecycle,
        stateMap: { _ in }
    )
    <> PersistentStoreMiddleware(service: RealmPersistenceService()).lift(  // TODO: Should be injected by World....
        inputActionMap: { globalAction in
            switch globalAction {
            case .appLifecycle(.didBecomeActive):
                return .subscribeToStoreChanges
            case .appLifecycle(.willBecomeInactive):
                return .cancelStoreSubscription
            case let .list(.add(task)):
                return .add(task)
            case let .list(.delete(id)):
                return .deleteTask(id)
            case let .list(.move(origin, offset)):
                return .moveTask(origin, offset)
            case let .list(.update(id, task)):
                return .updateTask(id, task)
            
            default:
                return nil
            }
        },
        outputActionMap: AppAction.persistentStore,
        stateMap: { _ in } /// i.e. Never (for the moment at least...)
    )



// MARK: - STORE
final class Store: ReduxStoreBase<AppAction, AppState> {
    private init() {
        super.init(
            subject: .combine(initialValue: .empty),
            reducer: Reducer.app,
            middleware: appMiddleware
        )
    }
    
    static let instance = Store()
}


// MARK: - WORLD
struct World {
    let store: () -> AnyStoreType<AppAction, AppState>
}

extension World {
    static let origin = World(store: { Store.instance.eraseToAnyStoreType() })
}
