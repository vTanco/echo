import Foundation

/// API Error types
enum APIError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case networkError(Error)
    case unauthorized
    case serverError(Int, String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .noData:
            return "No se recibieron datos"
        case .decodingError(let error):
            return "Error de decodificación: \(error.localizedDescription)"
        case .networkError(let error):
            return "Error de red: \(error.localizedDescription)"
        case .unauthorized:
            return "Sesión expirada. Inicia sesión de nuevo."
        case .serverError(let code, let message):
            return "Error del servidor (\(code)): \(message)"
        case .unknown:
            return "Error desconocido"
        }
    }
}

/// HTTP Methods
enum HTTPMethod: String {
    case GET, POST, PUT, PATCH, DELETE
}

/// API Client for Echo backend
class APIClient: ObservableObject {
    static let shared = APIClient()
    
    // Base URL - change for production
    #if DEBUG
    private let baseURL = "http://localhost:8000/api/v1"
    #else
    private let baseURL = "https://api.echocompute.com/api/v1"
    #endif
    
    @Published var isLoading = false
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    private init() {}
    
    // MARK: - Generic Request
    
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add auth header if required
        if requiresAuth, let token = AuthManager.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add body if present
        if let body = body {
            request.httpBody = try encoder.encode(body)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown
            }
            
            // Handle different status codes
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    return try decoder.decode(T.self, from: data)
                } catch {
                    throw APIError.decodingError(error)
                }
                
            case 401:
                // Try to refresh token
                if requiresAuth {
                    try await AuthManager.shared.refreshToken()
                    // Retry request
                    return try await self.request(endpoint: endpoint, method: method, body: body, requiresAuth: requiresAuth)
                }
                throw APIError.unauthorized
                
            case 400...499:
                let errorMessage = String(data: data, encoding: .utf8) ?? "Error del cliente"
                throw APIError.serverError(httpResponse.statusCode, errorMessage)
                
            case 500...599:
                throw APIError.serverError(httpResponse.statusCode, "Error interno del servidor")
                
            default:
                throw APIError.unknown
            }
            
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - Convenience Methods
    
    func get<T: Decodable>(_ endpoint: String, requiresAuth: Bool = true) async throws -> T {
        try await request(endpoint: endpoint, method: .GET, requiresAuth: requiresAuth)
    }
    
    func post<T: Decodable>(_ endpoint: String, body: Encodable? = nil, requiresAuth: Bool = true) async throws -> T {
        try await request(endpoint: endpoint, method: .POST, body: body, requiresAuth: requiresAuth)
    }
    
    func patch<T: Decodable>(_ endpoint: String, body: Encodable? = nil, requiresAuth: Bool = true) async throws -> T {
        try await request(endpoint: endpoint, method: .PATCH, body: body, requiresAuth: requiresAuth)
    }
    
    func delete(_ endpoint: String, requiresAuth: Bool = true) async throws {
        let _: EmptyResponse = try await request(endpoint: endpoint, method: .DELETE, requiresAuth: requiresAuth)
    }
}

/// Empty response for DELETE requests
struct EmptyResponse: Decodable {}

// MARK: - API Response Models

struct TokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
}

struct UserResponse: Codable {
    let id: String
    let email: String
    let displayName: String?
    let isActive: Bool
    let isVerified: Bool
    let totalEarnings: Double
    let availableBalance: Double
    let pendingWithdrawal: Double
    let totalComputeHours: Double
    let preferences: UserPreferences
    let createdAt: Date
}

struct UserPreferences: Codable {
    let autoStart: Bool
    let minBatteryLevel: Int
    let wifiOnly: Bool
    let scheduleEnabled: Bool
    let scheduleStart: String
    let scheduleEnd: String
    let notificationsEnabled: Bool
}

struct UserStatsResponse: Codable {
    let totalEarnings: Double
    let availableBalance: Double
    let pendingWithdrawal: Double
    let totalComputeHours: Double
    let totalSessions: Int
    let totalTasksCompleted: Int
    let devicesCount: Int
    let todayEarnings: Double
    let weekEarnings: Double
    let monthEarnings: Double
}

struct DeviceResponse: Codable {
    let id: String
    let userId: String
    let deviceToken: String
    let deviceName: String?
    let deviceModel: String?
    let batteryLevel: Double
    let isCharging: Bool
    let isOnWifi: Bool
    let temperature: Double
    let isActive: Bool
    let isComputing: Bool
    let isReadyForCompute: Bool
    let lastSeen: Date
    let totalTasksCompleted: Double
    let totalComputeHours: Double
    let totalEarnings: Double
}

struct SessionResponse: Codable {
    let id: String
    let userId: String
    let deviceId: String
    let startTime: Date
    let endTime: Date?
    let status: String
    let tasksCompleted: Double
    let tasksFailed: Double
    let earnings: Double
    let computeHours: Double
    let durationHours: Double
}

struct TaskResponse: Codable {
    let id: String
    let sessionId: String?
    let deviceId: String?
    let type: String
    let description: String?
    let clientName: String
    let clientLogo: String?
    let reward: Double
    let status: String
    let progress: Double
    let createdAt: Date
}

struct BalanceResponse: Codable {
    let availableBalance: Double
    let pendingWithdrawal: Double
    let totalEarnings: Double
}

struct EarningsProjection: Codable {
    let dailyAverage: Double
    let weeklyProjection: Double
    let monthlyProjection: Double
    let yearlyProjection: Double
}

// MARK: - ML Inference Task Models

/// Response from GET /tasks/next containing ML inference task details
struct MLTaskAPIResponse: Codable {
    let id: String
    let modelUrl: String
    let inputData: [String: AnyCodableValue]
    let expectedOutputType: String
    let reward: Double
    let clientName: String
    let clientLogo: String?
    let status: String
    let priority: Int
    let createdAt: Date
    let assignedAt: Date?
}

/// Request body for POST /tasks/{id}/submit
struct TaskResultSubmitRequest: Codable {
    let outputData: [String: AnyCodableValue]
    let inferenceTimeMs: Double
    let success: Bool
    let errorMessage: String?
}

/// Wrapper for heterogeneous JSON values (needed for model input/output)
enum AnyCodableValue: Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array([AnyCodableValue])
    case dictionary([String: AnyCodableValue])
    case null
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self = .null
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else if let double = try? container.decode(Double.self) {
            self = .double(double)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let array = try? container.decode([AnyCodableValue].self) {
            self = .array(array)
        } else if let dictionary = try? container.decode([String: AnyCodableValue].self) {
            self = .dictionary(dictionary)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode value")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .dictionary(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }
    
    /// Convert to native Swift Any type
    var anyValue: Any {
        switch self {
        case .string(let value): return value
        case .int(let value): return value
        case .double(let value): return value
        case .bool(let value): return value
        case .array(let value): return value.map { $0.anyValue }
        case .dictionary(let value): return value.mapValues { $0.anyValue }
        case .null: return NSNull()
        }
    }
    
    /// Create from native Swift Any type
    static func from(_ value: Any) -> AnyCodableValue {
        if let string = value as? String {
            return .string(string)
        } else if let int = value as? Int {
            return .int(int)
        } else if let double = value as? Double {
            return .double(double)
        } else if let bool = value as? Bool {
            return .bool(bool)
        } else if let array = value as? [Any] {
            return .array(array.map { from($0) })
        } else if let dict = value as? [String: Any] {
            return .dictionary(dict.mapValues { from($0) })
        } else {
            return .null
        }
    }
}

// MARK: - Dictionary Extension for AnyCodableValue

extension Dictionary where Key == String, Value == AnyCodableValue {
    /// Convert to [String: Any] dictionary
    var asAnyDict: [String: Any] {
        mapValues { $0.anyValue }
    }
    
    /// Create from [String: Any] dictionary
    static func from(_ dict: [String: Any]) -> [String: AnyCodableValue] {
        dict.mapValues { AnyCodableValue.from($0) }
    }
}

