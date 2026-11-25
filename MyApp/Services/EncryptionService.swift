//
//  EncryptionService.swift
//  Tipaba
//

import CryptoKit
import Foundation
import Security

enum EncryptionServiceError: LocalizedError {
    case invalidEncryptedData
    case invalidTextData
    case keychainFailure(OSStatus)

    var errorDescription: String? {
        switch self {
        case .invalidEncryptedData:
            return "The encrypted data is invalid or has been modified."
        case .invalidTextData:
            return "The decrypted data is not valid text."
        case .keychainFailure(let status):
            let message = SecCopyErrorMessageString(status, nil) as String? ?? "Unknown Keychain error"
            return "Unable to access the encryption key: \(message)"
        }
    }
}

final class EncryptionService {
    static let shared = EncryptionService()

    private let keychainService = "com.bocanasa.Tipaba.encryption"
    private let keychainAccount = "cloud-data-key"

    private init() {}

    func encrypt(_ value: String) throws -> Data {
        let key = try encryptionKey()
        let sealedBox = try AES.GCM.seal(Data(value.utf8), using: key)

        guard let combinedData = sealedBox.combined else {
            throw EncryptionServiceError.invalidEncryptedData
        }

        return combinedData
    }

    func decrypt(_ encryptedData: Data) throws -> String {
        let key = try encryptionKey()
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)

        guard let value = String(data: decryptedData, encoding: .utf8) else {
            throw EncryptionServiceError.invalidTextData
        }

        return value
    }

    private func encryptionKey() throws -> SymmetricKey {
        if let storedKey = try loadKey() {
            return SymmetricKey(data: storedKey)
        }

        let key = SymmetricKey(size: .bits256)
        let keyData = key.withUnsafeBytes { Data($0) }

        do {
            try storeKey(keyData)
            return key
        } catch EncryptionServiceError.keychainFailure(errSecDuplicateItem) {
            guard let storedKey = try loadKey() else {
                throw EncryptionServiceError.keychainFailure(errSecItemNotFound)
            }
            return SymmetricKey(data: storedKey)
        }
    }

    private func loadKey() throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecAttrSynchronizable as String: kSecAttrSynchronizableAny,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecUseDataProtectionKeychain as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        switch status {
        case errSecSuccess:
            guard let keyData = item as? Data else {
                throw EncryptionServiceError.invalidEncryptedData
            }
            return keyData
        case errSecItemNotFound:
            return nil
        default:
            throw EncryptionServiceError.keychainFailure(status)
        }
    }

    private func storeKey(_ keyData: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked,
            kSecAttrSynchronizable as String: true,
            kSecUseDataProtectionKeychain as String: true,
            kSecValueData as String: keyData
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw EncryptionServiceError.keychainFailure(status)
        }
    }
}
