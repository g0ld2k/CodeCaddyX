// -------------------------------------------------------------------------
//  KeychainService.swift
//  CodeCaddyX
//
//  Created by Chris Golding on 2023-04-19.
// -------------------------------------------------------------------------

import Foundation
import Security

/**
 An Error type used to represent various keychain errors, including saveFailed, loadFailed, deleteFailed, dataConversionFailed, noDataFound, unexpectedStatus.
 */
public enum KeychainError: Error {
    case saveFailed
    case loadFailed
    case deleteFailed
    case dataConversionFailed
    case noDataFound
    case unexpectedStatus(OSStatus)
}

/**
 A struct defining static key values for the keychain, including openAIAPIKey.
 */
public enum KeychainKeys {
    public static let openAIAPIKey = "openAIAPIKey"
}

/**
 A class that provides keychain read/write capabilities. The singleton instance can be accessed via the shared property.
 */
public class KeychainService {
    /**
     A shared singleton instance of KeychainService.
     */
    public static let shared = KeychainService()

    /**
     The keychain service name.
     */
    private let service = "com.g0ld2k.CodeCaddyX"

    /**
     Private initializer to ensure singleton pattern is followed.
     */
    private init() {}

    /**
     Saves a secret value with the given secretKey to the keychain. This is an async function that can throw KeychainError.

     - Parameters:
        - secret: The value to be saved.
        - secretKey: The key to associate with the value.
     */
    public func save(secret: String, secretKey: String) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await self.saveKey(secret: secret, secretKey: secretKey)
            }
            try await group.waitForAll()
        }
    }

    /**
     Loads a secret value for the given secretKey from the keychain. This is an async function that can throw KeychainError.

     - Parameter secretKey: The key to load the corresponding value.

     - Returns: The loaded value.
     */
    public func load(secretKey: String) async throws -> String {
        return try await withThrowingTaskGroup(of: String?.self) { group in
            group.addTask {
                try await self.loadKey(secretKey: secretKey)
            }
            for try await value in group {
                if let value = value {
                    return value
                }
            }
            throw KeychainError.loadFailed
        }
    }

    /**
     Deletes a secret value for the given secretKey from the keychain. This is an async function that can throw KeychainError.

     - Parameter secretKey: The key to delete the corresponding value.
     */
    public func delete(secretKey: String) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await self.deleteKey(secretKey: secretKey)
            }
            try await group.waitForAll()
        }
    }

    /**
     Internal helper function to save a secret value with the given secretKey to the keychain. This is an async function that can throw KeychainError.

     - Parameters:
        - secret: The value to be saved.
        - secretKey: The key to associate with the value.
     */
    private func saveKey(secret: String, secretKey: String) async throws {
        let keyData = secret.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: secretKey,
            kSecAttrService as String: service,
            kSecValueData as String: keyData,
        ]

        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            throw KeychainError.saveFailed
        }
    }

    /**
     Internal helper function to load a secret value for the given secretKey from the keychain. This is an async function that can throw KeychainError.

     - Parameter secretKey: The key to load the corresponding value.

     - Returns: The loaded value.
     */
    private func loadKey(secretKey: String) async throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: secretKey,
            kSecAttrService as String: service,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        switch status {
        case errSecSuccess:
            if let data = dataTypeRef as? Data, let value = String(data: data, encoding: .utf8) {
                return value
            }
            throw KeychainError.dataConversionFailed
        case errSecItemNotFound:
            throw KeychainError.noDataFound
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    /**
     Internal helper function to delete a secret value for the given secretKey from the keychain. This is an async function that can throw KeychainError.

     - Parameter secretKey: The key to delete the corresponding value.
     */
    private func deleteKey(secretKey: String) async throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: secretKey,
            kSecAttrService as String: service,
        ]

        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess {
            throw KeychainError.deleteFailed
        }
    }
}
