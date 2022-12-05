
import Foundation
import UIKit


class TaskAPIUsers {
    
    static let baseURL = "https://taskmanager-project-fall2022-zmoya.ondigitalocean.app/v1/"
    
    
    static func signUp( email : String,
                        name : String,
                        password : String,
                        successHandler: @escaping (_ httpStatusCode : Int, _ response : [String: Any]) -> Void,
                        failHandler : @escaping (_ httpStatusCode : Int, _ errorMessage: String) -> Void) {
        
        let endPoint = "users/signup"
        
        let header : [String:String] = [:]
        
        let payload : [String:String] = [ "email" : email, "name" : name, "password" : password]
        
        API.call(baseURL: baseURL, endPoint: endPoint, method: "POST", header: header, payload: payload, successHandler: successHandler, failHandler: failHandler)
        
    }
    
    
    static func signIn( email : String,
                        password : String,
                        successHandler: @escaping (_ httpStatusCode : Int, _ response : [String: Any]) -> Void,
                        failHandler : @escaping (_ httpStatusCode : Int, _ errorMessage: String) -> Void) {
        
        let endPoint = "users/login"
        
        let header : [String:String] = [:]
        
        let payload : [String:String] = [ "email" : email, "password" : password]
        
        API.call(baseURL: baseURL, endPoint: endPoint, method: "POST", header: header, payload: payload, successHandler: successHandler, failHandler: failHandler)
        
    }

    
    static func allUsers( token : String,
                        successHandler: @escaping (_ httpStatusCode : Int, _ response : [String: Any]) -> Void,
                        failHandler : @escaping (_ httpStatusCode : Int, _ errorMessage: String) -> Void) {
        
        let endPoint = "users/all"
        
        let header : [String:String] = ["x-access-token" : token]
        
        let payload : [String:String] = [:]
        
        API.call(baseURL: baseURL, endPoint: endPoint, method: "GET", header: header, payload: payload, successHandler: successHandler, failHandler: failHandler)
        
    }

}
