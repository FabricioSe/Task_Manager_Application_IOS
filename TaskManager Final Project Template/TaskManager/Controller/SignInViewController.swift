//
//  SignInViewController.swift
//  TaskManager
//
//  Created by Daniel Carvalho on 23/10/22.
//

import UIKit

class SignInViewController: UIViewController, UITextFieldDelegate, SignUpViewControllerDelegate {
    
    private var focusedTextField : UITextField?
    
    @IBOutlet var imgLogo : UIImageView!
    @IBOutlet var imgShowPassword : UIImageView!

    @IBOutlet var btnLogin : UIButton!
    @IBOutlet var btnSignUp : UIButton!

    @IBOutlet var txtLogin : UITextField!
    @IBOutlet var txtPassword : UITextField!

    @IBOutlet var swRememberMe : UISwitch!
    
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
    
    func customizeView() {
        
        imgLogo.layer.cornerRadius = Consts.Layout.smallLogoCornerRadious

        btnLogin.layer.cornerRadius = Consts.Layout.bigButtonCornerRadious
        btnSignUp.layer.cornerRadius = Consts.Layout.smallButtonCornerRadious
        
        imgShowPassword.enableTapGestureRecognizer(target: self, action: #selector(imgShowPasswordTapped(tapGestureRecognizer:)))

        
        // Handling keyboard show/hide
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        navigationItem.hidesBackButton = true
        
        txtLogin.delegate = self
        txtPassword.delegate = self
        
        
    }
    
    @objc private func keyboardWillShow( notification : NSNotification ){
        
        if self.focusedTextField == nil {
            return
        }
        
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
    
    
    @IBAction func btnLoginTouchUpInside() {
        
        if busy {
            return
        }
        
        var invalidTextFields : [UIView] = []
        
        if txtLogin.text!.isEmpty {
            invalidTextFields.append(txtLogin)
        }

        if txtPassword.text!.isEmpty {
            invalidTextFields.append(txtPassword)
        }
        
        if invalidTextFields.count > 0 {
            btnLogin.shakeWith(invalidTextFields)
            return
        }

        busy = true
        
        TaskAPIUsers.signIn(email: txtLogin.text!, password: txtPassword.text!) { httpStatusCode, response in
            
            self.busy = false
                        
            if httpStatusCode == 200 {
                
                Session.authorizationToken = response["token"] as? String
                Session.loggedUser = UserModel.decode(json: response["loggedUser"] as! [String : Any])
                AppContext.selectedUser = Session.loggedUser
                
                DispatchQueue.main.async {

                    self.txtPassword.text = ""
                    
                    self.performSegue(withIdentifier: Segue.toMainViewController, sender: nil)

                }
                    
            } else {
                
            }
            
        } failHandler: { httpStatusCode, errorMessage in
            
            self.busy = false

            DispatchQueue.main.async {
                Dialog.error(view: self, title: "Ooops! Error code \(httpStatusCode)!", message: errorMessage, okHandler: nil)
            }
            
        }

        
        
        
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if busy {
            return false
        }
        
        return true
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Segue.toSignUpViewController {
            
            let signUpViewController = segue.destination as! SignUpViewController
            signUpViewController.delegate = self
            
        }
        
    }
    
    
    func signUpViewController( newUserSignedUp : String, login: String, password: String) {
        
        txtLogin.text = login
        txtPassword.text = password
        
    }

    

}
