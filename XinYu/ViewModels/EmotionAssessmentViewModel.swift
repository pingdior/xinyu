import Foundation
import CoreML
import NaturalLanguage
import Combine

class EmotionAssessmentViewModel: ObservableObject {
    @Published var isProcessing = false
    @Published var currentAssessment: Assessment?
    @Published var recognizedText: String = ""
    @Published var assessmentResult: EmotionAssessmentResult = EmotionAssessmentResult.empty
    
    private let userId: UUID
    private let userStoragePreference: User.DataStoragePreference
    private let sentimentAnalyzer: NLModel?
    private let speechRecognitionManager = SpeechRecognitionManager()
    private let emotionClassifier = try? EmotionClassifier_1()
    private var cancellables = Set<AnyCancellable>()
    
    init(userId: UUID = UUID(), storagePreference: User.DataStoragePreference = .server) {
        self.userId = userId
        self.userStoragePreference = storagePreference
        // 初始化情感分析模型
        self.sentimentAnalyzer = try? NLModel(mlModel: EmotionClassifier_1().model)
        
        // 订阅语音识别结果
        speechRecognitionManager.$recognizedText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                self?.recognizedText = text
            }
            .store(in: &cancellables)
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
    
    func startRecording() {
        speechRecognitionManager.startRecording()
    }
    
    func stopRecording() {
        speechRecognitionManager.stopRecording()
    }
    
    func assessEmotion(text: String) {
        // 保存到本地数据库
        saveAssessmentToDatabase(text: text)
        
        // 分析情绪
        if let result = analyzeEmotion(text: text) {
            self.assessmentResult = result
        } else {
            // 如果模型分析失败，使用备用方法
            self.assessmentResult = fallbackEmotionAnalysis(text: text)
        }
    }
    
    private func analyzeEmotion(text: String) -> EmotionAssessmentResult? {
        guard let classifier = emotionClassifier, !text.isEmpty else { return nil }
        
        // 使用CoreML模型进行情绪分析
        do {
            // 注意：实际实现需要根据模型的输入格式准备数据
            // 这里是示例代码，需要根据实际模型调整
            guard let output = try? classifier.prediction(text: text) else { return nil }
            
            // 转换模型输出为评估结果
            let result = EmotionAssessmentResult(
                primaryEmotion: getPrimaryEmotion(from: output),
                positiveScore: output.positiveScore * 100,
                negativeScore: output.negativeScore * 100,
                joyScore: output.joyScore * 100,
                sadnessScore: output.sadnessScore * 100,
                angerScore: output.angerScore * 100,
                fearScore: output.fearScore * 100,
                anxietyScore: output.anxietyScore * 100,
                calmScore: output.calmScore * 100,
                stressLevel: getStressLevel(from: output),
                summary: generateSummary(from: output, text: text),
                suggestions: generateSuggestions(from: output)
            )
            return result
        } catch {
            print("情绪分析错误: \(error)")
            return nil
        }
    }
    
    private func fallbackEmotionAnalysis(text: String) -> EmotionAssessmentResult {
        // 简单的关键词分析作为备用
        let text = text.lowercased()
        
        // 简单情绪关键词匹配(中文)
        var joyScore: Double = 0
        var sadnessScore: Double = 0
        var angerScore: Double = 0
        var fearScore: Double = 0
        var anxietyScore: Double = 0
        var calmScore: Double = 0
        
        // 简单的关键词计数
        let joyWords = ["开心", "快乐", "高兴", "愉快", "兴奋", "喜悦"]
        let sadWords = ["难过", "伤心", "悲伤", "沮丧", "失落", "痛苦"]
        let angerWords = ["生气", "愤怒", "恼火", "烦躁", "暴怒", "不满"]
        let fearWords = ["害怕", "恐惧", "担心", "惊恐", "可怕", "惧怕"]
        let anxietyWords = ["焦虑", "紧张", "忧虑", "不安", "压力", "担忧"]
        let calmWords = ["平静", "放松", "安心", "舒适", "宁静", "安详"]
        
        for word in joyWords where text.contains(word) { joyScore += 20 }
        for word in sadWords where text.contains(word) { sadnessScore += 20 }
        for word in angerWords where text.contains(word) { angerScore += 20 }
        for word in fearWords where text.contains(word) { fearScore += 20 }
        for word in anxietyWords where text.contains(word) { anxietyScore += 20 }
        for word in calmWords where text.contains(word) { calmScore += 20 }
        
        // 限制最大值为100
        joyScore = min(joyScore, 100)
        sadnessScore = min(sadnessScore, 100)
        angerScore = min(angerScore, 100)
        fearScore = min(fearScore, 100)
        anxietyScore = min(anxietyScore, 100)
        calmScore = min(calmScore, 100)
        
        // 计算积极/消极分数
        let positiveScore = (joyScore + calmScore) / 2
        let negativeScore = (sadnessScore + angerScore + fearScore + anxietyScore) / 4
        
        // 确定主要情绪
        let emotions = [
            ("喜悦", joyScore),
            ("悲伤", sadnessScore),
            ("愤怒", angerScore),
            ("恐惧", fearScore),
            ("焦虑", anxietyScore),
            ("平静", calmScore)
        ]
        
        let primaryEmotion = emotions.max(by: { $0.1 < $1.1 })?.0 ?? "中性"
        
        // 确定压力水平
        let stressLevel: StressLevel
        if negativeScore >= 70 {
            stressLevel = .high
        } else if negativeScore >= 40 {
            stressLevel = .medium
        } else {
            stressLevel = .low
        }
        
        // 生成摘要
        let summary = "基于您的描述，我们检测到您主要的情绪倾向是\(primaryEmotion)。" +
                     "积极情绪指数为\(Int(positiveScore))%，消极情绪指数为\(Int(negativeScore))%。" +
                     "当前压力水平评估为\(stressLevel.rawValue)。"
        
        // 生成建议
        var suggestions: [String] = []
        
        if negativeScore > 60 {
            suggestions.append("建议进行5-10分钟的深呼吸练习，帮助缓解压力")
            suggestions.append("尝试与朋友或家人交流您的感受")
            if anxietyScore > 60 {
                suggestions.append("练习专注于当下的正念冥想")
            }
            if sadnessScore > 60 {
                suggestions.append("尝试进行一些您喜欢的活动，如听音乐或散步")
            }
        } else if negativeScore > 30 {
            suggestions.append("适当休息，保持规律的作息时间")
            suggestions.append("每天留出时间做自己喜欢的事情")
        } else {
            suggestions.append("继续保持良好的情绪状态")
            suggestions.append("定期进行自我关注，维持情绪平衡")
        }
        
        if suggestions.isEmpty {
            suggestions.append("保持健康的生活方式和积极的思考方式")
        }
        
        return EmotionAssessmentResult(
            primaryEmotion: primaryEmotion,
            positiveScore: positiveScore,
            negativeScore: negativeScore,
            joyScore: joyScore,
            sadnessScore: sadnessScore,
            angerScore: angerScore,
            fearScore: fearScore,
            anxietyScore: anxietyScore,
            calmScore: calmScore,
            stressLevel: stressLevel,
            summary: summary,
            suggestions: suggestions
        )
    }
    
    private func getPrimaryEmotion(from output: EmotionClassifier_1Output) -> String {
        // 根据模型输出确定主要情绪
        let emotions = [
            ("喜悦", output.joyScore),
            ("悲伤", output.sadnessScore),
            ("愤怒", output.angerScore),
            ("恐惧", output.fearScore),
            ("焦虑", output.anxietyScore),
            ("平静", output.calmScore)
        ]
        
        return emotions.max(by: { $0.1 < $1.1 })?.0 ?? "中性"
    }
    
    private func getStressLevel(from output: EmotionClassifier_1Output) -> StressLevel {
        let negativeScore = output.negativeScore
        
        if negativeScore >= 0.7 {
            return .high
        } else if negativeScore >= 0.4 {
            return .medium
        } else {
            return .low
        }
    }
    
    private func generateSummary(from output: EmotionClassifier_1Output, text: String) -> String {
        let primaryEmotion = getPrimaryEmotion(from: output)
        let positiveScore = Int(output.positiveScore * 100)
        let negativeScore = Int(output.negativeScore * 100)
        let stressLevel = getStressLevel(from: output)
        
        return "基于您的描述，我们检测到您主要的情绪倾向是\(primaryEmotion)。" +
               "积极情绪指数为\(positiveScore)%，消极情绪指数为\(negativeScore)%。" +
               "当前压力水平评估为\(stressLevel.rawValue)。"
    }
    
    private func generateSuggestions(from output: EmotionClassifier_1Output) -> [String] {
        var suggestions: [String] = []
        let negativeScore = output.negativeScore
        let anxietyScore = output.anxietyScore
        let sadnessScore = output.sadnessScore
        
        if negativeScore > 0.6 {
            suggestions.append("建议进行5-10分钟的深呼吸练习，帮助缓解压力")
            suggestions.append("尝试与朋友或家人交流您的感受")
            if anxietyScore > 0.6 {
                suggestions.append("练习专注于当下的正念冥想")
            }
            if sadnessScore > 0.6 {
                suggestions.append("尝试进行一些您喜欢的活动，如听音乐或散步")
            }
        } else if negativeScore > 0.3 {
            suggestions.append("适当休息，保持规律的作息时间")
            suggestions.append("每天留出时间做自己喜欢的事情")
        } else {
            suggestions.append("继续保持良好的情绪状态")
            suggestions.append("定期进行自我关注，维持情绪平衡")
        }
        
        if suggestions.isEmpty {
            suggestions.append("保持健康的生活方式和积极的思考方式")
        }
        
        return suggestions
    }
    
    private func saveAssessmentToDatabase(text: String) {
        // 使用CoreDataManager保存评估内容
        // 这部分实现取决于CoreData模型的结构
        CoreDataManager.shared.saveEmotionAssessment(
            content: text,
            timestamp: Date()
        )
    }
}