//
//  ServiceError.swift
//  Grocer
//
//  Created by Emil on 10/5/26.
//

import Foundation

enum ServiceError: Error {
    case invalidURL
    case badResponse
    case serverError(statusCode: Int)
    case decodingError(Error)
}

extension ServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .badResponse:
            return "Bad response"
        case .serverError(400):
            return "Request invalid."
        case .serverError(401):
            return "Invalid authentication, access denied."
        case .serverError(403):
            return "Unauthorized user, access denied."
        case .serverError(404):
            return "Requested object not found."
        case .serverError(500):
            return "Server crashed due tu unhandled exception."
        case .serverError(503):
            return "Server currently down for maintenance."
        case .serverError(statusCode: let statusCode):
            return "Unexpected error with status code: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}
