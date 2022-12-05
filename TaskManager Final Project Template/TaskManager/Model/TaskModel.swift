import Foundation
import UIKit


struct TaskModel : Codable {
    
    var taskUid : String
    var assignedToName : String
    var assignedToUid : String
    var createdByName : String
    var createdByUid : String
    var description : String
    var done : Bool
    
    
    static func decode( json : [String:Any] ) -> TaskModel? {
        
        let decoder = JSONDecoder()
        do{
            let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            let object = try decoder.decode(TaskModel.self, from: data)
            return object
        } catch {
        }
        return nil
    }
}


struct AllTasks : Codable {
    
    var allTasks : [TaskModel]
    
    static func decode( json : [String : Any] ) -> AllTasks? {
        
        let decoder = JSONDecoder()
        do{
            let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            let object = try decoder.decode(AllTasks.self, from: data)
            return object
        } catch {
        }
        return nil
    }
}

