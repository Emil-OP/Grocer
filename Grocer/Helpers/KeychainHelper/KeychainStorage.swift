//
//  KeychainStorage.swift
//  Grocer
//
//  Created by Emil on 7/15/26.
//

import SwiftUI

@propertyWrapper
struct KeychainStorage: DynamicProperty {
    private let key: String
    private let helper = KeychainHelper.shared
    
    @State private var value: String
    
    init(wrappedValue: String = "", _ key: String){
        self.key = key
        let existing = KeychainHelper.shared.readString(for: key)
        self._value = State(initialValue: existing ?? wrappedValue)
    }
    
    var wrappedValue: String {
        get{ value }
        nonmutating set{
            value = newValue
            if newValue.isEmpty{
                helper.delete(for: key)
            } else {
                helper.save(newValue, for: key)
            }
        }
    }
    
    var projectedValue: Binding<String>{
        Binding(get:{wrappedValue},set:{wrappedValue = $0})
    }
}

 
