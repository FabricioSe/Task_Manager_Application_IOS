//
//  TaskInfoViewController.swift
//  TaskManager
//
//  Created by Daniel Carvalho on 23/10/22.
//

import UIKit

protocol TaskInfoViewControllerDelegate {
    
    func taskInfoViewController( newTask taskUid : String )
    
}

class TaskInfoViewController: UIViewController, UITextFieldDelegate {

    var delegate : TaskInfoViewControllerDelegate?
    
    private var focusedTextView : UITextField?
    
    @IBOutlet var btnSave : UIButton!
    @IBOutlet var btnBack : UIButton!

    @IBOutlet var imgLogo : UIImageView!

    @IBOutlet var txtDescription : UITextField!
    @IBOutlet var lblAssignedTo : UILabel!
    
    
    
    
    
    @IBOutlet var actBusy : UIActivityIndicatorView!

    private var busy : Bool = false {
        didSet{
            DispatchQueue.main.async {
                if self.busy {
                    self.actBusy.isHidden = false
                    self.actBusy.startAnimating()
                } else {
                    self.actBusy.isHidden = true
                    self.actBusy.stopAnimating()
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        customizeView()
        
        initialize()

    }
    
    private func customizeView() {
        
        btnSave.layer.cornerRadius = Consts.Layout.bigButtonCornerRadious
        btnBack.layer.cornerRadius = Consts.Layout.smallButtonCornerRadious

        imgLogo.layer.cornerRadius = Consts.Layout.smallLogoCornerRadious

        btnBack.enableTapGestureRecognizer(target: self, action: #selector(btnBackTapped(tapGestureRecognizer:)))
        
        // Handling keyboard show/hide
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        
        navigationItem.hidesBackButton = true
        
        txtDescription.delegate = self

    }
    
    private func initialize() {
        
        lblAssignedTo.text = AppContext.selectedUser!.name.capitalized
        
        txtDescription.becomeFirstResponder()
        
    }

    
    @objc private func keyboardWillShow( notification : NSNotification ){
        
        if focusedTextView == nil {
            return
        }
        
        let containerMarginTop = self.view.frame.origin.y
        
        KeyboardLayoutAdapter.scrollToFit( notification : notification, viewController : self, focusedViewTag : self.focusedTextView!.tag, containerMarginTop: containerMarginTop)
        
        
    }
    
    @objc private func keyboardWillHide() {
        
        self.view.frame.origin.y = 0
        
    }
    
    /* when return key was pressed, keybord is dismissed */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.focusedTextView = textField
    }
    

    @objc func btnBackTapped(tapGestureRecognizer : UITapGestureRecognizer) {
        
        navigationController?.popViewController(animated: true)
        
    }

    @IBAction func btnSaveTapped() {
        
        if !checkFields() {
            return
        }
        
        self.busy = true
        
        TaskAPITasks.newTask(token: Session.authorizationToken!, description: txtDescription.text!, assignToUid: AppContext.selectedUser!.uid) { httpStatusCode, response in
            
            self.busy = false
            
            if httpStatusCode == 200 {

                DispatchQueue.main.async {
                    let taskUid = response["id"] as! String
                    
                    if self.delegate != nil {
                        self.delegate!.taskInfoViewController(newTask: taskUid)
                    }
                    
                    self.navigationController?.popViewController(animated: true)
                }
                
            } else {
                
                Dialog.error(view: self, title: "Ooops! Error code \(httpStatusCode)!", message: response["msg"] as! String) { action in
                    self.navigationController?.popViewController(animated: true)
                }
                
            }
            
        } failHandler: { httpStatusCode, errorMessage in
            
            self.busy = false

            DispatchQueue.main.async {
                Dialog.error(view: self, title: "Ooops! Error code \(httpStatusCode)!", message: errorMessage, okHandler: nil)
            }

        }

        
    }
    

    private func checkFields() -> Bool {
        
        if txtDescription.text!.isEmpty {
            
            txtDescription.shake()
            Dialog.error(view: self, title: "Ooops!", message: "Enter a valid task description.") { action in
                DispatchQueue.main.async {
                    self.txtDescription.becomeFirstResponder()
                }
            }
            return false
            
        }
        
        return true
        
    }


    
    
}
