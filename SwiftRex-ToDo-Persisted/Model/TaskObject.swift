//
//  ToDo.swift
//  SwiftRex-ToDo-Persisted
//
//  Created by Adrian Ward on 30/09/2020.
//

import Foundation
import Combine

import RealmSwift


@objcMembers
final class TaskObject: Object {
    dynamic private(set) var id: String = UUID().uuidString
    dynamic var index: Int = 0
    dynamic var name: String = ""
    dynamic var completed: Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(index: Int, name: String, completed: Bool = false) {
        self.init()
        self.index = index
        self.name = name
        self.completed = completed
    }
    
}


