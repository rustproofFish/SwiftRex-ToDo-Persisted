//
//  PersistenceMiddleware.swift
//  SwiftRex-ToDo-Persisted
//
//  Created by Adrian Ward on 30/09/2020.
//

import Foundation
import Combine

import SwiftRex


// MARK: - ACTION
enum PersistentStoreAction {
    case connectToStore // TODO: Not impl yet - use for Realm Sync connection
    case subscribeToStoreChanges
    case cancelStoreSubscription
    case add(Task)
    case deleteTask(String)
    case moveTask(IndexSet, Int)
    case updateTask(String, Task)
    case taskListModified([Task])
}


// MARK: - REDUCER
extension Reducer where ActionType == PersistentStoreAction, StateType == [Task] {
    static let persistentStore = Reducer { action, state in
        var state = state
        switch action {
        case .taskListModified(let value):
            // TODO: - Not sure if this is most efficient or should use ChangeSet?
            state = value
        default:
            /// other PersistanceMiddleware Actions do not mutate state directly
            break
        }
        return state
    }
}


//MARK: - MIDDLEWARE
class PersistentStoreMiddleware<S: PersistanceService>: Middleware where S.PersistableType == TaskObject, S.DTO == Task {
    typealias InputActionType = PersistentStoreAction
    typealias OutputActionType = PersistentStoreAction
    typealias StateType = Void /// leave as is for now but might want to set some global flags relating to the status of the store
    
    private let service: S
    private let state: StateType
    private var output: AnyActionHandler<OutputActionType>!
    private var cancellable = Set<AnyCancellable>()
    
    
    init(service: S) {
        self.service = service
    }
    
    
    func receiveContext(getState: @escaping GetState<Void>, output: AnyActionHandler<OutputActionType>) {
        /// observe system events here if necessary - remember State cannot be mutated outside a Reducer
        /// setup local properties if needed
        self.output = output
    }
    
    func handle(action: PersistentStoreAction, from dispatcher: ActionSource, afterReducer: inout AfterReducer) {
        switch action {
        case .connectToStore:
            NSLog("Connect to store - NOT CURRENTLY IMPLEMENTED")
        case .subscribeToStoreChanges:
            subscribeToStore(publisher: service.all())
        case .cancelStoreSubscription:
            cancelSubscription()
        case let .add(task):
            service.add(object: task)
        case let .deleteTask(id):
            service.deleteObject(id: id)
        case let .moveTask(origin, offset):
            service.moveObject(from: origin, to: offset)
        case let .updateTask(id, task):
            service.updateObject(id, using: task)
        default:
            break
        }
    }
    
    // MARK: - Private functions
    private func connectToStore() {
        /// if using on-device persistence this may be overkill
        /// however could be useful in the event that a cloud-based backend is utilised (check wifi/mobile reception, etc)
        // TODO: - IMPL
    }
    
    private func subscribeToStore(publisher: AnyPublisher<[Task], Never>) {
        /// accept a Publisher and subscribes to it
        /// objects received ([TaskDTO] in this example) encapsulated in an Action and dispatched to the ActionHandler. State then modified by a Reducer
        // TODO: - handle errors here?
        publisher
            .assertNoFailure() // TODO: refactor for better error handling e.g. return empty array and log error
            .sink { self.output.dispatch(.taskListModified($0)) }
            .store(in: &cancellable)
    }
    
    private func cancelSubscription() {
        cancellable = Set<AnyCancellable>()
    }
}
