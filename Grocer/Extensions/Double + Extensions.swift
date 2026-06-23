//
//  Double + Extensions.swift
//  Grocer
//
//  Created by Emil on 6/23/26.
//

import Foundation

extension Double {
    func roundedString() -> String {
        self.formatted(.number.precision(.fractionLength(2)))
    }
}
