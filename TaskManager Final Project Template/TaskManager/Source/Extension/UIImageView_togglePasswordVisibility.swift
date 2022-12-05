
import UIKit

extension UIImageView {
    
    func togglePasswordVisibility( forTextField : UITextField ) {
        
        forTextField.isSecureTextEntry = !forTextField.isSecureTextEntry
        
        if forTextField.isSecureTextEntry {
            self.image = UIImage(systemName: "eye.slash")
        } else {
            self.image = UIImage(systemName: "eye")
        }

    }
}
