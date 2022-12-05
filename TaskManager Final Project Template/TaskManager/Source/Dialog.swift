
import Foundation
import UIKit

class Dialog {
    
    // Variadic parameters
    // - passing multiple options without using arrays
    
    public struct DialogButton {
        
        var title : String = ""
        var style : UIAlertAction.Style = .default
        var handler : ((UIAlertAction) -> Void)? = nil
        /*
         example of handler implementation:
         //        let no = UIAlertAction(title: "No", style: .destructive, handler: {action in self.doNotDeleteFile()} )

         
         */
        
    }
    
    
    /* Example:
     ...
     let btnYes = Dialog.DialogButton(title: "Yes", style: .default, handler: {action in self.doSomething()})
     let btnNo = Dialog.DialogButton(title: "No", style: .destructive, handler: nil)
     let btnCancel = Dialog.DialogButton(title: "Cancel", style: .cancel, handler: nil)

     Dialog.show(view: self, title: "Title", message: "Message", style: .actionSheet, completion: nil, presentAnimated: true, buttons: btnYes, btnNo, btnCancel)
 
    
     */
    static func show ( view : UIViewController,
                       title : String,
                       message : String,
                       style : UIAlertController.Style,
                       completion : (() -> Void)?,
                       presentAnimated : Bool = true,
                       buttons : DialogButton... ) {
        
        
        var dialogStyle = style
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            dialogStyle = UIAlertController.Style.alert
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: dialogStyle)

        for button in buttons {
            let btn = UIAlertAction(title: button.title, style: button.style, handler: button.handler )
            alert.addAction(btn)
        }
        
        view.present(alert, animated: presentAnimated, completion: completion)
        
    }
    
    static func ok ( view : UIViewController,
                     title : String,
                     message : String,
                     style : UIAlertController.Style = .actionSheet,
                     okHandler : ((UIAlertAction) -> Void)?,
                     presentAnimated : Bool = true) {

        
        let btnOk = Dialog.DialogButton(title: "Ok", style: .default, handler: okHandler)
        Dialog.show(view: view, title: title, message: message, style: style, completion: nil, buttons: btnOk)
        
    }
    
    static func error ( view : UIViewController,
                     title : String,
                     message : String,
                     style : UIAlertController.Style = .actionSheet,
                     okHandler : ((UIAlertAction) -> Void)?,
                     presentAnimated : Bool = true) {

        
        let btnOk = Dialog.DialogButton(title: "Ok", style: .destructive, handler: okHandler)
        Dialog.show(view: view, title: title, message: message, style: style, completion: nil, buttons: btnOk)
        
    }
}
