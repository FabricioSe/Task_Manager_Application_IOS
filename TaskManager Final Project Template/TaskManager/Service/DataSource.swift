
import Foundation


class DataSource {
    
    static var allUsers : [UserModel] = [] {
        
        didSet{

            // moving the logged user for the first position of this array
            for i in (0..<allUsers.count){
                if allUsers[i].uid == Session.loggedUser!.uid {
                    allUsers.remove(at: i)
                    break
                }
            }
            allUsers.insert(Session.loggedUser!, at: 0)

        }
        
    }
    
    static var allTasks : [TaskModel] = []
    
}
