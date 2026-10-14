//
//  URL.swift
//  Grocer
//
//  Created by Emil on 10/9/26.
//

import Foundation

extension URL {
    static var apiBaseURL: URL{
        guard let string = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String,
              let url = URL(string: string) else {
            fatalError("BASE_URL missing or invalid")
        }
        return url
    }
}
