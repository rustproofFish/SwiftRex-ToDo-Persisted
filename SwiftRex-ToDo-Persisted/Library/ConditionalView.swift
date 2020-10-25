//
//  ConditionalView.swift
//  SwiftRex-ToDo-Persisted
//
//  Created by Adrian Ward on 16/10/2020.
//

import SwiftUI

struct UnwrapView<Value, Content: View>: View {
    private let value: Value?
    private let contentProvider: (Value) -> Content
    
    init(_ value: Value?, @ViewBuilder content: @escaping (Value) -> Content) {
        self.value = value
        self.contentProvider = content
    }
    
    var body: some View {
        value.map(contentProvider)
    }
}


struct ConditionalView<Content: View>: View {
    private let condition: Bool?
    private let contentProvider: (Bool) -> Content
    
    init(_ condition: Bool, @ViewBuilder content: @escaping (Bool) -> Content) {
        self.condition = condition ? condition : nil
        self.contentProvider = content
    }
    
    var body: some View {
        UnwrapView(condition, content: contentProvider)
    }
}
