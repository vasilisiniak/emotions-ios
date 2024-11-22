import Foundation
import Security

public protocol KeychainManager {
    func save(value: String?, forKey key: String) -> Bool
    func retrieve(key: String) -> String?
}

public final class KeychainManagerImpl {

    private enum Constants {
        static let PasscodeKey = "Model.KeychainManagerImpl.PasscodeKey"
        static let LockSourceKey = "Model.KeychainManagerImpl.LockSourceKey"
    }

    // MARK: - Private

    private func update(value: String, forKey key: String) -> Bool {

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: value.data(using: .utf8)!
        ]
        
        if SecItemUpdate(query as CFDictionary, attributes as CFDictionary) == noErr {
            return true
        }
        else {
            print("Error while updating value \(value) for key \(key) in keychain")
            return false
        }
    }

    // MARK: - Public

    public init() {}
}

extension KeychainManagerImpl: KeychainManager {

    public func save(value: String?, forKey key: String) -> Bool {

        if let value {

            if retrieve(key: key) != nil {
                return update(value: value, forKey: key)
            }

            let attributes: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecValueData as String: value.data(using: .utf8)!
            ]

            if SecItemAdd(attributes as CFDictionary, nil) == noErr {
                return true
            }
            else {
                print("Error while saving value \(value) for key \(key) to keychain")
                return false
            }
        }
        else {

            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key
            ]

            if SecItemDelete(query as CFDictionary) == noErr {
                return true
            }
            else {
                print("Error while deleting value for key \(key) from keychain")
                return false
            }
        }
    }
    
    public func retrieve(key: String) -> String? {

        var item: CFTypeRef?

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]

        let err = SecItemCopyMatching(query as CFDictionary, &item)

        if err == errSecItemNotFound {
            return nil
        }

        if err == noErr {

            let item = item as? [String: Any]
            let data = item?[kSecValueData as String] as? Data

            if let data {
                return String(data: data, encoding: .utf8)
            }
            else {
                return nil
            }
        }
        else {
            print("Error while retrieving value for key \(key) from keychain")
            return nil
        }
    }
}

extension KeychainManagerImpl: LockManagerStorage {

    public func getLockSource() -> String? {
        retrieve(key: Constants.LockSourceKey)
    }
    
    public func setLockSource(source: String) -> Bool {
        return save(value: source, forKey: Constants.LockSourceKey)
    }

    public func clearLockSource() -> Bool {
        return save(value: nil, forKey: Constants.LockSourceKey)
    }

    public func getPasscode() -> String? {
        retrieve(key: Constants.PasscodeKey)
    }

    public func savePasscode(_ passcode: String) -> Bool {
        return save(value: passcode, forKey: Constants.PasscodeKey)
    }
    
    public func clearPasscode() -> Bool {
        return save(value: nil, forKey: Constants.PasscodeKey)
    }
}
