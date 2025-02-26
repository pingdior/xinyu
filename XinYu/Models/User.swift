import Foundation

struct User: Identifiable, Codable {
    enum DataStoragePreference: String, Codable {
        case server // 默认服务器存储
        case hybrid // 数据分级存储
        case local  // 完全本地存储
    }
    
    let id: UUID
    let username: String
    let email: String
    var dataStoragePreference: DataStoragePreference
    
    init(
        id: UUID = UUID(),
        username: String,
        email: String,
        dataStoragePreference: DataStoragePreference = .server
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.dataStoragePreference = dataStoragePreference
    }
}