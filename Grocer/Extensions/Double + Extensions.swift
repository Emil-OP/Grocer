//
//  Double + Extensions.swift
//  Grocer
//
//  Created by Emil on 6/23/26.
//

import Foundation

extension Double {
    func roundedString(precision : Int = 2) -> String {
        self.formatted(.number.precision(.fractionLength(precision)))
    }
    
    
}
