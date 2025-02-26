import XCTest
@testable import XinYu

class NetworkServiceTests: XCTestCase {
    var networkService: NetworkService!
    var testAssessment: Assessment!
    
    override func setUp() {
        super.setUp()
        networkService = NetworkService.shared
        testAssessment = Assessment(
            userId: UUID(),
            inputText: "测试数据",
            inputType: .text,
            positiveScore: 0.7,
            negativeScore: 0.3,
            stressLevel: 0.4,
            anxietyLevel: 0.3,
            riskLevel: .low,
            reportText: "测试报告"
        )
    }
    
    override func tearDown() {
        networkService = nil
        testAssessment = nil
        super.tearDown()
    }
    
    func testUploadFullAssessment() async throws {
        do {
            try await networkService.uploadFullAssessment(testAssessment)
            // 如果没有抛出错误，则测试通过
            XCTAssert(true)
        } catch {
            XCTFail("上传完整评估数据失败: \(error)")
        }
    }
    
    func testUploadAnonymizedAssessment() async throws {
        let anonymizedData = [
            "positiveScore": testAssessment.positiveScore,
            "negativeScore": testAssessment.negativeScore,
            "stressLevel": testAssessment.stressLevel,
            "anxietyLevel": testAssessment.anxietyLevel,
            "riskLevel": testAssessment.riskLevel.rawValue
        ] as [String : Any]
        
        do {
            try await networkService.uploadAnonymizedAssessment(anonymizedData)
            // 如果没有抛出错误，则测试通过
            XCTAssert(true)
        } catch {
            XCTFail("上传匿名评估数据失败: \(error)")
        }
    }
    
    func testNetworkError() async {
        // 测试服务器错误情况
        do {
            try await networkService.uploadFullAssessment(testAssessment)
            XCTFail("应该抛出错误")
        } catch NetworkError.serverError {
            // 预期的错误，测试通过
            XCTAssert(true)
        } catch {
            XCTFail("抛出了意外的错误类型")
        }
    }
}