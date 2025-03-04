import Foundation

struct User {
    enum DataStoragePreference {
        case server  // 所有数据存储在服务器
        case hybrid  // 匿名数据存储在服务器，敏感数据存储在本地
        case local   // 所有数据仅存储在本地
    }
    
    let id: UUID
    let storagePreference: DataStoragePreference
}