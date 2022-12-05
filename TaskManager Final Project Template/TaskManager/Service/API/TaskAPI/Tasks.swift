
import Foundation
import UIKit


class TaskAPITasks {
    
    static let baseURL = "https://taskmanager-project-fall2022-zmoya.ondigitalocean.app/v1/"
    
    
    static func createdBy( token : String,
                           successHandler: @escaping (_ httpStatusCode : Int, _ response : [String: Any]) -> Void,
                           failHandler : @escaping (_ httpStatusCode : Int, _ errorMessage: String) -> Void) {
        
        let endPoint = "tasks/createdby"
        
        let header : [String:String] = ["x-access-token" : token]
        
        let payload : [String:String] = [:]
        
        API.call(baseURL: baseURL, endPoint: endPoint, method: "GET", header: header, payload: payload, successHandler: successHandler, failHandler: failHandler)
        
    }
    
    
    static func assignedTo( token : String,
                            successHandler: @escaping (_ httpStatusCode : Int, _ response : [String: Any]) -> Void,
                            failHandler : @escaping (_ httpStatusCode : Int, _ errorMessage: String) -> Void) {
        
        let endPoint = "tasks/assignedto"
        
        let header : [String:String] = ["x-access-token" : token]
        
        let payload : [String:String] = [:]
        
        API.call(baseURL: baseURL, endPoint: endPoint, method: "GET", header: header, payload: payload, successHandler: successHandler, failHandler: failHandler)
        
    }
    
    
    static func newTask( token : String,
                         description : String,
                         assignToUid : String,
                         successHandler: @escaping (_ httpStatusCode : Int, _ response : [String: Any]) -> Void,
                         failHandler : @escaping (_ httpStatusCode : Int, _ errorMessage: String) -> Void) {
        
        let endPoint = "tasks"
        
        let header : [String:String] = ["x-access-token" : token]
        
        let payload : [String:String] = ["description" : description, "assignedToUid" : assignToUid]
        
        API.call(baseURL: baseURL, endPoint: endPoint, method: "POST", header: header, payload: payload, successHandler: successHandler, failHandler: failHandler)
        
    }
    
    
    static func deleteTask( token : String,
                         taskUid : String,
                         successHandler: @escaping (_ httpStatusCode : Int, _ response : [String: Any]) -> Void,
                         failHandler : @escaping (_ httpStatusCode : Int, _ errorMessage: String) -> Void) {
        
        let endPoint = "tasks/\(taskUid)"
        
        let header : [String:String] = ["x-access-token" : token]
        
        let payload : [String:String] = [:]
        
        API.call(baseURL: baseURL, endPoint: endPoint, method: "DELETE", header: header, payload: payload, successHandler: successHandler, failHandler: failHandler)
        
    }
    
    static func setTaskDone( token : String,
                             taskUid : String,
                             done : Bool,
                             successHandler: @escaping (_ httpStatusCode : Int, _ response : [String: Any]) -> Void,
                             failHandler : @escaping (_ httpStatusCode : Int, _ errorMessage: String) -> Void) {
        
        let endPoint = "tasks/\(taskUid)"
        
        let header : [String:String] = ["x-access-token" : token]
        
        let payload : [String:Bool] = ["done" : done]
        
        API.call(baseURL: baseURL, endPoint: endPoint, method: "PATCH", header: header, payload: payload, successHandler: successHandler, failHandler: failHandler)
        
    }
    
}


