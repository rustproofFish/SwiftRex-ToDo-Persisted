//
//  RealmPersistance.swift
//  SwiftRex-ToDo-Persisted
//
//  Created by Adrian Ward on 09/10/2020.
//

import Foundation
import Combine

import RealmSwift

// MARK: - PROTOCOL
protocol PersistanceService {
    associatedtype RealmObject: DTORepresentable
    var subject: CurrentValueSubject<[RealmObject.DTO], Never> { get }
    var cancellables: Set<AnyCancellable> { get }
    
    func all(matching predicate: NSPredicate, in realm: Realm) -> AnyPublisher<[RealmObject.DTO], Never>
    
    func add(object properties: RealmObject.DTO, in realm: Realm) -> AnyPublisher<RealmObject, Never>
    
    func update(_ object: RealmObject, using dto: RealmObject.DTO, in realm: Realm)
    
    func delete(_ object: RealmObject, in realm: Realm)
    
    func deleteObject(id: String, in realm: Realm)
    
    func deleteObjects(matching predicate: (TaskObject) -> Bool, in realm: Realm)
    
    func moveObject(from orgin: IndexSet, to destination: Int, in realm: Realm)
}


// MARK: - EXTENSION
extension PersistanceService {
    // Using extension to allow default parameters for methods
    func all(matching predicate: NSPredicate = NSPredicate(value: true), in realm: Realm = try! Realm()) -> AnyPublisher<[RealmObject.DTO], Never> {
        all(matching: predicate, in: realm)
    }
    
    @discardableResult
    func add(object properties: RealmObject.DTO, in realm: Realm = try! Realm()) -> AnyPublisher<RealmObject, Never> {
        add(object: properties, in: realm)
    }
    
    func update(_ object: RealmObject, using dto: RealmObject.DTO, in realm: Realm = try! Realm()) {
        update(object, using: dto, in: realm)
    }
    
    func delete(_ object: RealmObject, in realm: Realm = try! Realm()) {
        delete(object, in: realm)
    }
    
    func deleteObject(id: String, in realm: Realm = try! Realm()) {
        deleteObject(id: id, in: realm)
    }
    
    func deleteObjects(matching predicate: (TaskObject) -> Bool, in realm: Realm = try! Realm()) {
        deleteObjects(matching: predicate, in: realm)
    }
    
    func moveObject(from origin: IndexSet, to destination: Int, in realm: Realm = try! Realm()) {
        moveObject(from: origin, to: destination, in: realm)
    }
}


// MARK: - IMPLEMENTATION
final class RealmPersistenceService: PersistanceService {
    /// Not entirely comfortable about conversion to Array as we lose the lazy behaviour of Results...
    /// However Results cannot be direcly instantiated thus can't be used as the Element within a CurrentValueSubject
    /// Need to ensure that as much work (e.g. filtering, sorting) is done using Result prior to conversion to the DTO array
    internal let subject = CurrentValueSubject<[TaskObject.DTO], Never>([])
    internal var cancellables = Set<AnyCancellable>()
    
    // TODO: - Consider rewriting to allow error handling related to Realm errors.
    // According to developers, Realm failures only arise on first attempt to access Realm on a given thread so trapping is only
    // required here...
    func all(matching predicate: NSPredicate = NSPredicate(value: true), in realm: Realm) -> AnyPublisher<[TaskObject.DTO], Never> {
        realm.objects(TaskObject.self)
            .filter(predicate)
            .collectionPublisher
            .assertNoFailure()
            .freeze()
            .map { item in
                item
                    .sorted(byKeyPath: "index") // TODO: Enable different sort descriptors
                    .map { $0.convertToDTO() }
            }
            
            .receive(on: DispatchQueue.main)
            .subscribe(subject) /// using a Subject to facilitate pipeline sharing and buffering of last output
            .store(in: &cancellables)
        
        return subject.eraseToAnyPublisher()
    }
    
    
    @discardableResult
    func add(object properties: TaskObject.DTO, in realm: Realm) -> AnyPublisher<TaskObject, Never> {
        let index = realm.objects(TaskObject.self).count
        let task = TaskObject(index: index, name: properties.name)
        try! realm.write {
            realm.add(task)
        }
        
        return Just(task).eraseToAnyPublisher()
    }
    
    
    func update(_ object: TaskObject, using dto: TaskObject.DTO, in realm: Realm) {
        // TODO: Consider using rollback implementation in the event of errors
        // TODO: Return the amended Task or work on the assumption that no crash means success?
        try! realm.write {
            object.name = dto.name
        }
    }
    
    
    func delete(_ object: TaskObject, in realm: Realm) {
        let index = object.index
        try! realm.write {
            realm.delete(object)
            
            /// IMPORTANT: Although it would be tempting to use .filter with .map to update a Realm collection, Results is *lazy*
            /// so the .map closure never executes. Imperative rather than functional code is required here
            let objectsWithInvalidIndices = realm.objects(TaskObject.self).filter { $0.index > index}
            objectsWithInvalidIndices.forEach { $0.index -= 1 }
        }
    }
    
    
    func deleteObject(id: String, in realm: Realm) {
        guard let object = realm.objects(TaskObject.self).filter({ $0.id == id }).first else { return } // TODO: Guard failure -> Throw? Log?
        delete(object, in: realm)
    }
    
    
    func deleteObjects(matching predicate: (TaskObject) -> Bool, in realm: Realm) {
        guard let object = realm.objects(TaskObject.self).filter(predicate).first else { return } // TODO: Guard failure -> Throw? Log?
        delete(object, in: realm)
    }
    
    
    func moveObject(from origin: IndexSet, to destination: Int, in realm: Realm) {
        var proxy = Array(realm.objects(TaskObject.self)
                            .sorted(byKeyPath: "index")
                            .map { (index: $0.index, id: $0.id) })
        
        let targetObject = proxy.remove(at: origin.first!) // remove target from proxy
        if destination < proxy.count {
            proxy.insert(targetObject, at: destination) // reinsert at new position
        } else {
            proxy.append(targetObject) // prevents index out of range error when moved to end of SwiftUI List
        }
        
        try! realm.write {
            proxy.enumerated()
                .map { (offset, element) in
                    if element.index != offset {
                        realm.create(TaskObject.self, value: ["id": element.id, "index": offset], update: .modified)
                    }
                }
        }
    }

    
    deinit {
        cancellables = []
    }
}
