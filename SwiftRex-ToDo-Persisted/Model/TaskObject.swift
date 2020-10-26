//
//  ToDo.swift
//  SwiftRex-ToDo-Persisted
//
//  Created by Adrian Ward on 30/09/2020.
//

import Foundation
import Combine

import RealmSwift

// TODO: - Can I use codegen (e.g. Sourcery) to automatically generate the DTO?
protocol DTORepresentable: Object {
    associatedtype DTO
    func convertToDTO() -> DTO
}

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

extension TaskObject: DTORepresentable {
    struct DTO: Equatable, Identifiable {
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
        
        init(name: String) {
            self.name = name
        }
        
        fileprivate init(index: Int, name: String) {
            self.init(name: name)
            self.index = index
        }
    }
    
    func convertToDTO() -> TaskObject.DTO {
        var dto = DTO(index: index, name: name)
        dto.id = id
        return dto
    }
}

