import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "XinYu")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("无法加载Core Data存储: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                fatalError("保存Core Data上下文失败: \(error)")
            }
        }
    }
    
    // MARK: - Assessment CRUD Operations
    
    func saveAssessment(_ assessment: Assessment) {
        let managedAssessment = AssessmentEntity(context: context)
        managedAssessment.id = assessment.id
        managedAssessment.userId = assessment.userId
        managedAssessment.inputText = assessment.inputText
        managedAssessment.inputType = assessment.inputType.rawValue
        managedAssessment.assessmentTimestamp = assessment.assessmentTimestamp
        managedAssessment.positiveScore = assessment.positiveScore
        managedAssessment.negativeScore = assessment.negativeScore
        managedAssessment.stressLevel = assessment.stressLevel
        managedAssessment.anxietyLevel = assessment.anxietyLevel
        managedAssessment.riskLevel = assessment.riskLevel.rawValue
        managedAssessment.reportText = assessment.reportText
        
        saveContext()
    }
    
    func fetchAssessments(for userId: UUID) -> [Assessment] {
        let fetchRequest: NSFetchRequest<AssessmentEntity> = AssessmentEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId == %@", userId as CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "assessmentTimestamp", ascending: false)]
        
        do {
            let managedAssessments = try context.fetch(fetchRequest)
            return managedAssessments.map { managedAssessment in
                Assessment(
                    id: managedAssessment.id ?? UUID(),
                    userId: managedAssessment.userId ?? UUID(),
                    inputText: managedAssessment.inputText ?? "",
                    inputType: Assessment.InputType(rawValue: managedAssessment.inputType ?? "text") ?? .text,
                    assessmentTimestamp: managedAssessment.assessmentTimestamp ?? Date(),
                    positiveScore: managedAssessment.positiveScore,
                    negativeScore: managedAssessment.negativeScore,
                    stressLevel: managedAssessment.stressLevel,
                    anxietyLevel: managedAssessment.anxietyLevel,
                    riskLevel: Assessment.RiskLevel(rawValue: managedAssessment.riskLevel ?? "low") ?? .low,
                    reportText: managedAssessment.reportText ?? ""
                )
            }
        } catch {
            print("获取评估记录失败: \(error)")
            return []
        }
    }
    
    func deleteAssessment(id: UUID) {
        let fetchRequest: NSFetchRequest<AssessmentEntity> = AssessmentEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            if let assessment = try context.fetch(fetchRequest).first {
                context.delete(assessment)
                saveContext()
            }
        } catch {
            print("删除评估记录失败: \(error)")
        }
    }
}