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
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(index: Int, name: String) {
        self.init()
        self.index = index
        self.name = name
    }
    
}


