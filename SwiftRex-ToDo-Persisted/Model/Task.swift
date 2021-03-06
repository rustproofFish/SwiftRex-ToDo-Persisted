//
//  TaskDTO.swift
//  SwiftRex-ToDo-Persisted
//
//  Created by Adrian Ward on 26/10/2020.
//

import Foundation

protocol DataTransferObject: Equatable, Identifiable {
    associatedtype O
    static func from(_ object: O) -> Self
} // TODO: - Marker protocol only for now but perhaps better to be a bit more meaningful?


struct Task: DataTransferObject {
    fileprivate (set) var id: String = UUID().uuidString /// identifier shouldn't be set directly - only allocated when Task Objects are instantiated
    var _index: Int? /// index is dependent on the number of tasks so should only be set by the persistence layer
    var index: Int {
        get {
            guard let idx = _index else { fatalError("Attempting to access index before value has been set") }
            return idx
        }
        set {
            _index = newValue
        }
    }
    var name: String
    var completed: Bool
    
    init(name: String) {
        self.name = name
        self.completed = false
    }
    
    static func from(_ object: TaskObject) -> Self {
        var dto = Task(index: object.index, name: object.name, completed: object.completed)
        dto.id = object.id
        return dto
    }
    
    fileprivate init(index: Int, name: String, completed: Bool) {
        self.init(name: name)
        self.index = index
        self.completed = completed
    }
}

