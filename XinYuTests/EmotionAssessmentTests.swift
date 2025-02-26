import XCTest
import CoreML
import NaturalLanguage
@testable import XinYu

class EmotionAssessmentTests: XCTestCase {
    var viewModel: EmotionAssessmentViewModel!
    let testUserId = UUID()
    
    override func setUp() {
        super.setUp()
        viewModel = EmotionAssessmentViewModel(userId: testUserId, storagePreference: .local)
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testEmotionAssessmentPositive() async throws {
        let positiveText = "今天心情非常好，一切都很顺利，充满希望。"
        let assessment = try await viewModel.performAssessment(text: positiveText, inputType: .text)
        
        XCTAssertNotNil(assessment)
        XCTAssertGreaterThan(assessment.positiveScore, 0.5)
        XCTAssertLessThan(assessment.negativeScore, 0.5)
        XCTAssertEqual(assessment.riskLevel, .low)
    }
    
    func testEmotionAssessmentNegative() async throws {
        let negativeText = "我感到非常焦虑和压抑，很不安。"
        let assessment = try await viewModel.performAssessment(text: negativeText, inputType: .text)
        
        XCTAssertNotNil(assessment)
        XCTAssertGreaterThan(assessment.negativeScore, 0.5)
        XCTAssertGreaterThan(assessment.stressLevel, 0.5)
        XCTAssertGreaterThan(assessment.anxietyLevel, 0.5)
    }
    
    func testEmotionAssessmentNeutral() async throws {
        let neutralText = "今天天气不错。"
        let assessment = try await viewModel.performAssessment(text: neutralText, inputType: .text)
        
        XCTAssertNotNil(assessment)
        XCTAssertLessThan(abs(assessment.positiveScore - assessment.negativeScore), 0.3)
        XCTAssertLessThan(assessment.stressLevel, 0.3)
        XCTAssertLessThan(assessment.anxietyLevel, 0.3)
    }
    
    func testReportGeneration() async throws {
        let text = "我最近工作压力很大，经常失眠。"
        let assessment = try await viewModel.performAssessment(text: text, inputType: .text)
        
        XCTAssertNotNil(assessment.reportText)
        XCTAssertTrue(assessment.reportText.contains("情绪评估报告"))
        XCTAssertTrue(assessment.reportText.contains("建议"))
    }
    
    func testLocalDataStorage() async throws {
        let text = "测试数据存储功能。"
        let assessment = try await viewModel.performAssessment(text: text, inputType: .text)
        viewModel.saveAssessment(assessment)
        
        let savedAssessments = CoreDataManager.shared.fetchAssessments(for: testUserId)
        XCTAssertTrue(savedAssessments.contains { $0.id == assessment.id })
    }
}