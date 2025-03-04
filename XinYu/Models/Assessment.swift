import Foundation

struct Assessment: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let inputText: String
    let inputType: InputType
    let assessmentTimestamp: Date
    let positiveScore: Float
    let negativeScore: Float
    let stressLevel: Float
    let anxietyLevel: Float
    let riskLevel: RiskLevel
    let reportText: String
    
    enum InputType: String, Codable {
        case text = "文本"
        case voice = "语音"
    }
    
    enum RiskLevel: String, Codable {
        case low = "低风险"
        case medium = "中等风险"
        case high = "高风险"
    }
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        inputText: String,
        inputType: InputType,
        assessmentTimestamp: Date = Date(),
        positiveScore: Float = 0.0,
        negativeScore: Float = 0.0,
        stressLevel: Float = 0.0,
        anxietyLevel: Float = 0.0,
        riskLevel: RiskLevel = .low,
        reportText: String = ""
    ) {
        self.id = id
        self.userId = userId
        self.inputText = inputText
        self.inputType = inputType
        self.assessmentTimestamp = assessmentTimestamp
        self.positiveScore = positiveScore
        self.negativeScore = negativeScore
        self.stressLevel = stressLevel
        self.anxietyLevel = anxietyLevel
        self.riskLevel = riskLevel
        self.reportText = reportText
    }
}