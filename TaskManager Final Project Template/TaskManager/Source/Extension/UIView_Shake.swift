

import Foundation
import UIKit

extension UIView {

    func shakeWith( _ viewsToShakeWith : UIView... ){
        
        self.shake()
        
        for view in viewsToShakeWith {
            view.shake()
        }
        
    }
    
    func shakeWith( _ viewsToShakeWith : [UIView] ){
        
        self.shake()
        
        for view in viewsToShakeWith {
            view.shake()
        }
        
    }
    
    func shake() {
        
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        
        animation.timingFunction = CAMediaTimingFunction(name: .default)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        
        layer.add(animation, forKey: "shake")
    }

}
