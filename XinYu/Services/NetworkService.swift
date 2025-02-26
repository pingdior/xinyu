import Foundation

class NetworkService {
    static let shared = NetworkService()
    private let baseURL = ProcessInfo.processInfo.environment["API_BASE_URL"] ?? "https://api.xinyu.com" // 从环境变量读取API地址
    
    private init() {}
    
    func uploadFullAssessment(_ assessment: Assessment) async throws {
        let url = URL(string: "\(baseURL)/api/assessments")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(assessment)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError
        }
    }
    
    func uploadAnonymizedAssessment(_ data: [String: Any]) async throws {
        let url = URL(string: "\(baseURL)/api/assessments/anonymous")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        request.httpBody = jsonData
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError
        }
    }
}

enum NetworkError: Error {
    case serverError
}