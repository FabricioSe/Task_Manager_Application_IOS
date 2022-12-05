import Foundation
import UIKit


struct UserModel : Codable {
    
    var uid : String
    var name : String
    var email : String
    
    
    static func decode( json : [String:Any] ) -> UserModel? {
        
        let decoder = JSONDecoder()
        do{
            let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            let object = try decoder.decode(UserModel.self, from: data)
            return object
        } catch {
        }
        return nil
    }
}


struct AllUsers : Codable {
    
    var allUsers : [UserModel]
    
    static func decode( json : [String : Any] ) -> AllUsers? {
        
        let decoder = JSONDecoder()
        do{
            let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            let object = try decoder.decode(AllUsers.self, from: data)
            return object
        } catch {
        }
        return nil
    }
}

