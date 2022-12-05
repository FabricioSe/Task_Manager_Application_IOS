//
//  SignUpViewController.swift
//  TaskManager
//
//  Created by Daniel Carvalho on 23/10/22.
//

import UIKit

protocol SignUpViewControllerDelegate {
    
    func signUpViewController ( newUserSignedUp name : String, login : String, password : String )
    
}



class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    var delegate : SignUpViewControllerDelegate?
    
    private var focusedTextField : UITextField?
    
    @IBOutlet var btnSave : UIButton!
    @IBOutlet var btnBack : UIButton!
    
    @IBOutlet var imgShowPassword : UIImageView!
    @IBOutlet var imgLogo : UIImageView!
    
    @IBOutlet var txtName : UITextField!
    @IBOutlet var txtLogin : UITextField!
    @IBOutlet var txtPassword : UITextField!
    
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
    }
    
    
    func customizeView(){
        
        btnSave.layer.cornerRadius = Consts.Layout.bigButtonCornerRadious
        btnBack.layer.cornerRadius = Consts.Layout.smallButtonCornerRadious
        
        imgLogo.layer.cornerRadius = Consts.Layout.smallLogoCornerRadious
        
        imgShowPassword.enableTapGestureRecognizer(target: self, action: #selector(imgShowPasswordTapped(tapGestureRecognizer: )))
        
        btnBack.enableTapGestureRecognizer(target: self, action: #selector(btnBackTapped(tapGestureRecognizer: )))
        btnSave.enableTapGestureRecognizer(target: self, action: #selector(btnSaveTapped(tapGestureRecognizer: )))
        
        
        // Handling keyboard show/hide
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        navigationItem.hidesBackButton = true
        
        txtName.delegate = self
        txtLogin.delegate = self
        txtPassword.delegate = self
        
        
    }
    
    
    @objc private func keyboardWillShow( notification : NSNotification ){
        
        let containerMarginTop = self.view.frame.origin.y
        
        KeyboardLayoutAdapter.scrollToFit( notification : notification, viewController : self, focusedViewTag : self.focusedTextField!.tag, containerMarginTop: containerMarginTop)
        
        
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
        self.focusedTextField = textField
    }
    
    @objc func imgShowPasswordTapped(tapGestureRecognizer : UITapGestureRecognizer) {
        
        imgShowPassword.togglePasswordVisibility(forTextField: txtPassword)
        
    }
    
    @objc func btnBackTapped(tapGestureRecognizer : UITapGestureRecognizer) {
        
        if busy {
            return
        }
        
        navigationController?.popViewController(animated: true)
        
    }
    
    
    @objc func btnSaveTapped(tapGestureRecognizer : UITapGestureRecognizer) {

        if busy {
            return
        }
        
        busy = true
        
        if !checkFields() {
            busy = false
            return
        }

        TaskAPIUsers.signUp(email: txtLogin.text!, name: txtName.text!, password: txtPassword.text!) { httpStatusCode, response in

            self.busy = false
            
            DispatchQueue.main.async {
                if httpStatusCode == 200 {
                    Dialog.ok(view: self, title: "Welcome", message: "Welcome \(self.txtName.text!)! Now you can enjoy our app!") { action in
                        
                        if self.delegate != nil {
                            self.delegate!.signUpViewController(newUserSignedUp: self.txtName.text!, login: self.txtLogin.text!, password: self.txtPassword.text!)
                        }
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    Dialog.error(view: self, title: "Ooops! Error code \(httpStatusCode)!", message: response["msg"] as! String) { action in
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            
        } failHandler: { httpStatusCode, errorMessage in
            
            self.busy = false

            DispatchQueue.main.async {
                Dialog.error(view: self, title: "Ooops! Error code \(httpStatusCode)!", message: errorMessage, okHandler: nil)
            }

        }

        
    }
    
    /// Form fields validation
    func checkFields() -> Bool {
        
        guard let name = txtName.text, name.count >= 2  else {
            txtName.shake()
            Dialog.error(view: self, title: "Ooops!", message: "Enter a name with at least 2 chars!") { action in
                DispatchQueue.main.async {
                    self.txtName.becomeFirstResponder()
                }
            }
            return false
        }
        
        guard let login = txtLogin.text, login.isValidEmail() else {
            txtLogin.shake()
            Dialog.error(view: self, title: "Ooops!", message: "Enter a valid email address!") { action in
                DispatchQueue.main.async {
                    self.txtLogin.becomeFirstResponder()
                }
            }
            return false
        }

        guard let password = txtPassword.text, password.count >= 4, password.count <= 12 else {
            txtPassword.shake()
            Dialog.error(view: self, title: "Ooops!", message: "Your password should have between 4 and 12 chars!") { action in
                DispatchQueue.main.async {
                    self.txtPassword.becomeFirstResponder()
                }
            }
            return false
        }
        
        return true
        
    }
    
}
