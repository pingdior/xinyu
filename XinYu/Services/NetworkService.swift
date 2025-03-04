import Foundation

protocol NetworkSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: NetworkSessionProtocol {}

class NetworkService {
    static let shared = NetworkService()
    private let baseURL = ProcessInfo.processInfo.environment["API_BASE_URL"] ?? "https://api.xinyu.com" // 从环境变量读取API地址
    private let session: NetworkSessionProtocol
    
    private init(urlSession: NetworkSessionProtocol = URLSession.shared) {
        self.session = urlSession
    }
    
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
    
    func sendAnonymousData(data: [String: Any], completion: @escaping (Bool, Error?) -> Void) {
        guard let url = URL(string: "\(baseURL)/analytics") else {
            completion(false, NSError(domain: "com.xinyu.error", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: data)
        } catch {
            completion(false, error)
            return
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(false, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(false, NSError(domain: "com.xinyu.error", code: 500, userInfo: [NSLocalizedDescriptionKey: "Server error"]))
                return
            }
            
            completion(true, nil)
        }
        
        task.resume()
    }
}

enum NetworkError: Error {
    case serverError
}