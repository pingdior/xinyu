import Foundation
import CoreML
import NaturalLanguage

class EmotionAssessmentViewModel: ObservableObject {
    @Published var isProcessing = false
    @Published var currentAssessment: Assessment?
    
    private let userId: UUID
    private let userStoragePreference: User.DataStoragePreference
    private let sentimentAnalyzer: NLModel?
    
    init(userId: UUID = UUID(), storagePreference: User.DataStoragePreference = .server) {
        self.userId = userId
        self.userStoragePreference = storagePreference
        // 初始化情感分析模型
        self.sentimentAnalyzer = try? NLModel(mlModel: EmotionClassifier_1().model)
    }
    
    func performAssessment(text: String, inputType: Assessment.InputType) async throws -> Assessment {
        isProcessing = true
        defer { isProcessing = false }
        
        // 使用CoreML模型进行情绪评估
        let (positiveScore, negativeScore) = analyzeSentiment(text)
        let (stressLevel, anxietyLevel) = analyzeEmotionalState(text)
        let riskLevel = determineRiskLevel(stressLevel: stressLevel, anxietyLevel: anxietyLevel)
        
        let assessment = Assessment(
            userId: userId,
            inputText: text,
            inputType: inputType,
            positiveScore: positiveScore,
            negativeScore: negativeScore,
            stressLevel: stressLevel,
            anxietyLevel: anxietyLevel,
            riskLevel: riskLevel,
            reportText: generateReport(text: text, positiveScore: positiveScore, negativeScore: negativeScore, stressLevel: stressLevel, anxietyLevel: anxietyLevel, riskLevel: riskLevel)
        )
        
        currentAssessment = assessment
        return assessment
    }
    
    private func analyzeSentiment(_ text: String) -> (Float, Float) {
        guard let analyzer = sentimentAnalyzer else {
            return (0.5, 0.5) // 默认值
        }
        
        let prediction = analyzer.predictedLabel(for: text) ?? ""
        let confidence = analyzer.predictedLabelHypotheses(for: text, maximumCount: 2)
        
        let positiveScore = Float(confidence["Positive"] ?? 0.5)
        let negativeScore = Float(confidence["Negative"] ?? 0.5)
        
        return (positiveScore, negativeScore)
    }
    
    private func analyzeEmotionalState(_ text: String) -> (Float, Float) {
        // 基于关键词和语言模式分析压力和焦虑水平
        let stressKeywords = ["压力", "紧张", "疲惫", "不堪重负", "焦虑", "烦躁", "压抑", "沮丧", "困扰", "崩溃"]
        let anxietyKeywords = ["担心", "害怕", "恐惧", "慌张", "不安", "忧虑", "惊慌", "恐慌", "惶恐", "忐忑"]
        
        // 情绪强度修饰词
        let intensifiers = ["非常", "很", "特别", "极其", "太", "真的", "好", "超级"]
        
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        var stressScore = 0.0
        var anxietyScore = 0.0
        var intensifierMultiplier = 1.0
        
        for (index, word) in words.enumerated() {
            // 检查是否有强度修饰词
            if intensifiers.contains(where: { word.contains($0) }) {
                intensifierMultiplier = 1.5
                continue
            }
            
            // 分析压力关键词
            if stressKeywords.contains(where: { word.contains($0) }) {
                stressScore += 1.0 * intensifierMultiplier
            }
            
            // 分析焦虑关键词
            if anxietyKeywords.contains(where: { word.contains($0) }) {
                anxietyScore += 1.0 * intensifierMultiplier
            }
            
            // 重置强度修饰符
            intensifierMultiplier = 1.0
        }
        
        // 考虑文本长度和关键词密度
        let textLength = Float(words.count)
        let stressLevel = min(Float(stressScore) / textLength * 3.0, 1.0)
        let anxietyLevel = min(Float(anxietyScore) / textLength * 3.0, 1.0)
        
        return (stressLevel, anxietyLevel)
    }
    
    private func determineRiskLevel(stressLevel: Float, anxietyLevel: Float) -> Assessment.RiskLevel {
        let combinedScore = (stressLevel + anxietyLevel) / 2.0
        
        switch combinedScore {
        case 0.0...0.3:
            return .low
        case 0.3...0.7:
            return .medium
        default:
            return .high
        }
    }
    
    private func generateReport(text: String, positiveScore: Float, negativeScore: Float, stressLevel: Float, anxietyLevel: Float, riskLevel: Assessment.RiskLevel) -> String {
        let emotionalState = determineEmotionalState(positiveScore: positiveScore, negativeScore: negativeScore)
        let suggestions = generateSuggestions(riskLevel: riskLevel, stressLevel: stressLevel, anxietyLevel: anxietyLevel)
        
        return """
        情绪评估报告：
        1. 情绪状态：\(emotionalState)
        2. 风险等级：\(riskLevel.rawValue)
        3. 详细分析：
           - 积极情绪指数：\(String(format: "%.1f", positiveScore * 100))%
           - 消极情绪指数：\(String(format: "%.1f", negativeScore * 100))%
           - 压力水平：\(String(format: "%.1f", stressLevel * 100))%
           - 焦虑水平：\(String(format: "%.1f", anxietyLevel * 100))%
        
        4. 建议：
        \(suggestions)
        
        注意：本评估仅供参考，如有需要请及时寻求专业帮助。
        """
    }
    
    private func determineEmotionalState(positiveScore: Float, negativeScore: Float) -> String {
        if positiveScore > 0.7 {
            return "积极乐观"
        } else if negativeScore > 0.7 {
            return "情绪低落"
        } else if positiveScore > negativeScore {
            return "相对平稳"
        } else {
            return "略显消极"
        }
    }
    
    private func generateSuggestions(riskLevel: Assessment.RiskLevel, stressLevel: Float, anxietyLevel: Float) -> String {
        var suggestions = [String]()
        
        switch riskLevel {
        case .low:
            suggestions.append("   - 保持规律作息")
            suggestions.append("   - 适度运动")
            suggestions.append("   - 进行深呼吸练习")
        case .medium:
            suggestions.append("   - 尝试冥想或放松练习")
            suggestions.append("   - 与亲友倾诉交流")
            suggestions.append("   - 适当调整工作节奏")
            suggestions.append("   - 保证充足睡眠")
        case .high:
            suggestions.append("   - 建议寻求专业心理咨询")
            suggestions.append("   - 进行正念减压练习")
            suggestions.append("   - 适当减少工作压力")
            suggestions.append("   - 多与家人朋友交流")
            suggestions.append("   - 规律作息，保持健康生活方式")
        }
        
        return suggestions.joined(separator: "\n")
    }
    
    func saveAssessment(_ assessment: Assessment) {
        // 保存到本地CoreData
        CoreDataManager.shared.saveAssessment(assessment)
        
        // 根据用户的数据存储偏好处理数据上传
        switch userStoragePreference {
        case .server:
            // 上传完整数据到服务器
            uploadFullAssessment(assessment)
        case .hybrid:
            // 上传匿名化的非敏感数据
            uploadAnonymizedAssessment(assessment)
        case .local:
            // 完全本地存储，不上传数据
            break
        }
    }
    
    private func uploadFullAssessment(_ assessment: Assessment) {
        Task {
            do {
                try await NetworkService.shared.uploadFullAssessment(assessment)
            } catch {
                print("上传完整评估数据失败: \(error)")
            }
        }
    }
    
    private func uploadAnonymizedAssessment(_ assessment: Assessment) {
        // 创建匿名化的评估数据，仅包含非敏感信息
        let anonymizedData = [
            "positiveScore": assessment.positiveScore,
            "negativeScore": assessment.negativeScore,
            "stressLevel": assessment.stressLevel,
            "anxietyLevel": assessment.anxietyLevel,
            "riskLevel": assessment.riskLevel.rawValue
        ]
        
        Task {
            do {
                try await NetworkService.shared.uploadAnonymizedAssessment(anonymizedData)
            } catch {
                print("上传匿名评估数据失败: \(error)")
            }
        }
    }
}