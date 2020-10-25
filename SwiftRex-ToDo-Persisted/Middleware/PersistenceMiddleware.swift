//
//  PersistenceMiddleware.swift
//  SwiftRex-ToDo-Persisted
//
//  Created by Adrian Ward on 30/09/2020.
//

import Foundation
import Combine

import RealmSwift
import SwiftRex

/*
 - when app first launched, connect to the store (crash and produce diagnostics if any issue here)
 - observe all AppActions - we may want to respond to multiple unconnected substates, e.g. AppLifecycle, specific view-associated Actions
 - start observing the persistent store when the app becomes active in the background
 - stop observing the persistent store when the app becomes inactive
 - use a loopback approach, i.e. the Middleware responds to lifecycle / view Actions by dispatching Middleware-specific actions which result in the desired side effects. For example, AppLifecycleAction.willBecomeInactive -> dispatch(MiddlewareAction.cancelSubscription) -> cancel the subscription to Publishers of persisted objects
 - the above approach is recommended although the side effect will be delayed by one RunLoop - will this be a significant delay?
 */

// MARK: - ACTION
enum PersistentStoreAction {
    case connectToStore
    case subscribeToChanges
    case cancelSubscription
    case taskListModified([TaskObject.DTO])
}


// MARK: - REDUCER
extension Reducer where ActionType == PersistentStoreAction, StateType == [TaskObject.DTO] {
    static let persistentStore = Reducer { action, state in
        var state = state
        switch action {
        case .connectToStore:
            NSLog("Connecting to store")
        case .subscribeToChanges:
            NSLog("Subscribing for Realm changes")
        case .cancelSubscription:
            NSLog("Connecting to store")
        case .taskListModified(let value): // TODO: - Not sure if this is most efficient or should use ChangeSet?
            state = value
        }
        return state
    }
}


//MARK: - MIDDLEWARE
class PersistentStoreMiddleware<S: PersistanceService>: Middleware where S.RealmObject == TaskObject {
    typealias InputActionType = AppAction // needs to respond to Actions generated throughout application
    typealias OutputActionType = PersistentStoreAction
    typealias StateType = Void // leave as is for now but might want to set some global flags relating to the status of the store
    
    private let service: S
    private let state: StateType
    private var output: AnyActionHandler<OutputActionType>!
    private var cancelleable = Set<AnyCancellable>()
    
    
    init(service: S) {
        self.service = service
    }
    
    
    func receiveContext(getState: @escaping GetState<Void>, output: AnyActionHandler<OutputActionType>) {
        // observe system events here if necessary
        // setup local properties
        self.output = output
    }
    
    func handle(action: InputActionType, from dispatcher: ActionSource, afterReducer: inout AfterReducer) {
        switch action {
        case .appLifecycle(.didBecomeActive):
            output.dispatch(.subscribeToChanges)
        case .appLifecycle(.willBecomeInactive):
            output.dispatch(.cancelSubscription)
            
        case .persistentStore(.connectToStore):
            print("*** Check store accessible ***")
        case .persistentStore(.subscribeToChanges):
            subscribe(to: service.all())
            
        case let .list(.add(task)):
            service.add(object: task)
        case let .list(.delete(id)):
            service.deleteObject(id: id)
        case let .list(.move(fromIndex, toIndex)):
            service.moveObject(from: fromIndex, to: toIndex)
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
    
    private func subscribe(to publisher: AnyPublisher<[TaskObject.DTO], Never>) {
        /// accept a Publisher and subscribes to it
        /// objects received ([TaskObject.DTO] in this example) encapsulated in an Action and dispatched to the ActionHandler. State then modified by a Reducer
        // TODO: - handle errors here?
        publisher
            .assertNoFailure() // refactor for better error handling e.g. return empty array and log error
            .sink { self.output.dispatch(.taskListModified($0)) }
            .store(in: &cancelleable)
    }
    
    private func cancelSubscription() {
        _ = cancelleable
            .map { $0.cancel() } // this might be a redundent step
        cancelleable.removeAll()
    }
}
