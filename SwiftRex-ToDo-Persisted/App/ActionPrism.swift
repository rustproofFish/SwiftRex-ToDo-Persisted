//
//  ActionPrism.swift
//  SwiftRex-ToDo-Persisted
//
//  Created by Adrian Ward on 12/10/2020.
//

import Foundation

// TODO: - Use codegen (Sourcery)
/// Prisms allow associated values to be extracted from Action enums - there might be a bit more to this though!
extension AppAction {
    public var appLifecycle: AppLifecycleAction? {
        get {
            guard case let .appLifecycle(value) = self else { return nil }
            return value
        }
        set {
            guard case .appLifecycle = self, let newValue = newValue else { return }
            self = .appLifecycle(newValue)
        }
    }
    
    public var isAppLifecycle: Bool {
        self.appLifecycle != nil
    }
}


extension AppAction {
    public var persistentStore: PersistentStoreAction? {
        get {
            guard case let .persistentStore(value) = self else { return nil }
            return value
        }
        set {
            guard case .persistentStore = self, let newValue = newValue else { return }
            self = .persistentStore(newValue)
        }
    }
    
    public var isPersistentStore: Bool {
        self.persistentStore != nil
    }
}


extension AppAction {
    public var list: ListAction? {
        get {
            guard case let .list(value) = self else { return nil }
            return value
        }
        set {
            guard case .list = self, let newValue = newValue else { return }
            self = .list(newValue)
        }
    }
    
    public var isList: Bool {
        self.list != nil
    }
}


extension AppAction {
    public var task: TaskAction? {
        get {
            guard case let .task(value) = self else { return nil }
            return value
        }
        set {
            guard case .task = self, let newValue = newValue else { return }
            self = .task(newValue)
        }
    }
    
    public var isTask: Bool {
        self.task != nil
    }
}



