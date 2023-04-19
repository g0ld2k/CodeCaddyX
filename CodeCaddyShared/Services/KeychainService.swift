// -------------------------------------------------------------------------
//  KeychainService.swift
//  CodeCaddyX
//
//  Created by Chris Golding on 2023-04-19.
// -------------------------------------------------------------------------

import Foundation
import Security

public enum KeychainError: Error {
    case saveFailed
    case loadFailed
    case deleteFailed
    case dataConversionFailed
    case noDataFound
    case unexpectedStatus(OSStatus)
}

public enum KeychainKeys {
    public static let openAIAPIKey = "openAIAPIKey"
}

public class KeychainService {

    public static let shared = KeychainService()

    private let service = "com.g0ld2k.CodeCaddyX"

    private init() {}

    public func save(secret: String, secretKey: String) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await self.saveKey(secret: secret, secretKey: secretKey)
            }
            try await group.waitForAll()
        }
    }

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

    public func delete(secretKey: String) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await self.deleteKey(secretKey: secretKey)
            }
            try await group.waitForAll()
        }
    }

    private func saveKey(secret: String, secretKey: String) async throws {
        let keyData = secret.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: secretKey,
            kSecAttrService as String: service,
            kSecValueData as String: keyData
        ]

        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            throw KeychainError.saveFailed
        }
    }

    private func loadKey(secretKey: String) async throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: secretKey,
            kSecAttrService as String: service,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
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

    private func deleteKey(secretKey: String) async throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: secretKey,
            kSecAttrService as String: service
        ]

        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess {
            throw KeychainError.deleteFailed
        }
    }
}

