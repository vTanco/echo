import Foundation
import Security
import UIKit

/// Authentication manager for handling user session
@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    // Published state
    @Published var isAuthenticated = false
    @Published var currentUser: UserResponse?
    @Published var isLoading = false
    
    // Token storage keys
    private let accessTokenKey = "echo_access_token"
    private let refreshTokenKey = "echo_refresh_token"
    private let deviceIdKey = "echo_device_id"
    
    private init() {
        // Check for existing tokens on init
        if accessToken != nil {
            isAuthenticated = true
            Task {
                await loadCurrentUser()
            }
        }
    }
    
    // MARK: - Token Access
    
    var accessToken: String? {
        get { KeychainHelper.read(key: accessTokenKey) }
        set {
            if let value = newValue {
                KeychainHelper.save(key: accessTokenKey, value: value)
            } else {
                KeychainHelper.delete(key: accessTokenKey)
            }
        }
    }
    
    private var refreshTokenValue: String? {
        get { KeychainHelper.read(key: refreshTokenKey) }
        set {
            if let value = newValue {
                KeychainHelper.save(key: refreshTokenKey, value: value)
            } else {
                KeychainHelper.delete(key: refreshTokenKey)
            }
        }
    }
    
    /// Current registered device ID
    var currentDeviceId: String? {
        get { UserDefaults.standard.string(forKey: deviceIdKey) }
        set { UserDefaults.standard.set(newValue, forKey: deviceIdKey) }
    }
    
    // MARK: - Auth Methods
    
    struct LoginRequest: Encodable {
        let email: String
        let password: String
    }
    
    struct RegisterRequest: Encodable {
        let email: String
        let password: String
        let displayName: String?
    }
    
    func login(email: String, password: String) async throws {
        await MainActor.run { isLoading = true }
        defer { Task { @MainActor in isLoading = false } }
        
        let request = LoginRequest(email: email, password: password)
        let response: TokenResponse = try await APIClient.shared.post("/auth/login/json", body: request, requiresAuth: false)
        
        saveTokens(response)
        await loadCurrentUser()
        
        // Register device if not already registered
        if currentDeviceId == nil {
            await registerDevice()
        }
        
        await MainActor.run {
            isAuthenticated = true
            HapticManager.shared.success()
        }
    }
    
    func register(email: String, password: String, displayName: String?) async throws {
        await MainActor.run { isLoading = true }
        defer { Task { @MainActor in isLoading = false } }
        
        let request = RegisterRequest(email: email, password: password, displayName: displayName)
        let _: UserResponse = try await APIClient.shared.post("/auth/register", body: request, requiresAuth: false)
        
        // Auto-login after register
        try await login(email: email, password: password)
    }
    
    func logout() {
        accessToken = nil
        refreshTokenValue = nil
        currentDeviceId = nil
        
        Task { @MainActor in
            currentUser = nil
            isAuthenticated = false
            HapticManager.shared.mediumImpact()
        }
    }
    
    func refreshToken() async throws {
        guard let refresh = refreshTokenValue else {
            throw APIError.unauthorized
        }
        
        struct RefreshRequest: Encodable {
            let refreshToken: String
        }
        
        let request = RefreshRequest(refreshToken: refresh)
        let response: TokenResponse = try await APIClient.shared.post("/auth/refresh", body: request, requiresAuth: false)
        
        saveTokens(response)
    }
    
    // MARK: - User
    
    func loadCurrentUser() async {
        do {
            let user: UserResponse = try await APIClient.shared.get("/users/me")
            await MainActor.run {
                currentUser = user
            }
        } catch {
            print("Failed to load user: \(error)")
        }
    }
    
    func loadUserStats() async throws -> UserStatsResponse {
        try await APIClient.shared.get("/users/me/stats")
    }
    
    // MARK: - Device Registration
    
    /// Register this device with the backend
    func registerDevice() async {
        let device = UIDevice.current
        
        struct DeviceRegisterRequest: Encodable {
            let deviceToken: String
            let deviceName: String?
            let deviceModel: String?
            let osVersion: String?
            let appVersion: String?
        }
        
        let deviceToken = UUID().uuidString // Generate unique device token
        let request = DeviceRegisterRequest(
            deviceToken: deviceToken,
            deviceName: device.name,
            deviceModel: device.model,
            osVersion: device.systemVersion,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        )
        
        do {
            let response: DeviceResponse = try await APIClient.shared.post("/devices/register", body: request)
            await MainActor.run {
                self.currentDeviceId = response.id
            }
            print("✅ Device registered: \(response.id)")
        } catch {
            print("❌ Failed to register device: \(error)")
        }
    }
    
    // MARK: - Private Helpers
    
    private func saveTokens(_ response: TokenResponse) {
        accessToken = response.accessToken
        refreshTokenValue = response.refreshToken
    }
}

// MARK: - Keychain Helper

private enum KeychainHelper {
    static func save(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    static func read(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let string = String(data: data, encoding: .utf8) {
            return string
        }
        
        return nil
    }
    
    static func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
