//
//  KeychainHelper.swift
//  Grocer
//
//  Created by Emil on 7/14/26.
//

import Foundation
import Security

final class KeychainHelper: Sendable {

    static let shared = KeychainHelper()  //Singleton
    private let service: String  // App's bundle ID
    init(service: String = Bundle.main.bundleIdentifier ?? "com.app.default") {
        self.service = service
    }

    //MARK: - SAVE (Create/Update)
    
    /// Stores new sensitive information within Keychain's Dictionary via creating a new entry or updating an already existing entry.
    /// - Parameters:
    ///   - data: Data object representing the sensitive information to be stored.
    ///   - key: String representing the key used to retrieve/interact with an element within the Keychain Dictionary.
    func save(_ data: Data, for key: String) {

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let updateStatus = SecItemUpdate(
            query as CFDictionary,
            attributes as CFDictionary
        )

        if updateStatus == errSecItemNotFound {
            var newItem = query
            newItem[kSecValueData as String] = data
            let addStatus = SecItemAdd(newItem as CFDictionary, nil)
            if addStatus != errSecSuccess {
                print("Error adding item to keychan \(addStatus)")
            } else {
                print("Keychain save successful.")
            }
        } else if updateStatus != errSecSuccess {
            print("Keychain failed to update: \(updateStatus)")
        }
    }

    //MARK: - READ
    
    /// Returns an Optional Data object representing the counterpart of the key String received in Keychain's Dictionary.
    /// - Parameter key: String representing the key used to retrieve/interact with an element within the Keychain Dictionary.
    /// - Returns: Optional Data object containing sensitive information.
    func read(for key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else { return nil }

        return result as? Data
    }

    //MARK: - DELETE
    
    /// Deletes the Keychain's Dictionary entry corresponding to the key string received.
    /// - Parameter key: String representing the key used to retrieve/interact with an element within the Keychain Dictionary.
    func delete(for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]

        let status = SecItemDelete(query as CFDictionary)

        if status != errSecSuccess && status != errSecItemNotFound {
            print("Keychan item deletion failed \(status)")
        }
    }

    //MARK: - Convenience
    
    /// Overloaded convenience method for KeychainHelper's save function. Rather than accepting a Data type object, it will receive a String, convert the String object to a Data object, and finally pass the Data object onto the acual Keychain storage
    /// - Parameters:
    ///   - value: String representing the sensitive information to be stored.
    ///   - key: String representing the key used to retrieve/interact with an element within the Keychain Dictionary.
    func save(_ value: String, for key: String) {
        guard let data = value.data(using: .utf8) else { return }
        save(data, for: key)
    }
    
    /// Overloaded convenience method for KeychainHelper's read function. Receives a String to access an element in the Keychain Dicionary and passes it on to the read function within KeychainHelper. Rather than returning an Optional Data object, it will return an Optional String object.
    /// - Parameter key: String representing the key used to retrieve/interact with an element within the Keychain Dictionary.
    /// - Returns: Optional String converted from an Option Data.
    func readString(for key: String) -> String? {
        guard let data = read(for: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }

}
