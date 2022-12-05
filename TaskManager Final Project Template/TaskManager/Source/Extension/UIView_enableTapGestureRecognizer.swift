//
//  UIView_enableTapGestureRecognizer.swift
//  IOS-FinalProject-LSBank
//
//  Created by user203175 on 11/5/21.
//

import Foundation
import UIKit


extension UIView{
    

    func enableTapGestureRecognizer( target : Any?, action : Selector? ) {
        /*
         (e.g: call) image.enableTapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
         
         (e.g: @objc func)
         @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
         {
             let tappedImage = tapGestureRecognizer.view as! UIImageView
             delegate?.selectProfileImage(image: tappedImage.image)
             navigationController!.popViewController(animated: true)
         }
         */
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: target, action: action)
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tapGestureRecognizer)
        
        
    }
    
}

