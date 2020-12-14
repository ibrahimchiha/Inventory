//
//  RegisterViewController.swift
//  Intentory+
//
//  Created by Ibrahim Chiha on 12/13/20.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class RegisterViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    let containerView : UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray4.cgColor
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let registerTitleLabel : UILabel = {
        let label = UILabel()
        label.text = "Welcome to Inventory+"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let emailTextField : UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let separatorTextField : UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let passwordTextField : UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let registerButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Account", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor.systemBlue
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let switchAuthButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Already have an account?", for: .normal)
        button.addTarget(self, action: #selector(switchAuth), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc func switchAuth() {
        self.showMessage(with: "Info", message: "If you already have an account, enter the details and you'll get logged in automagically!")
    }
    
    func setupView() {
        navigationItem.title = "Register"
        view.backgroundColor = .white
        view.addSubview(registerTitleLabel)
        registerTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registerTitleLabel.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -100).isActive = true
        registerTitleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 4/5).isActive = true
        registerTitleLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(containerView)
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: registerTitleLabel.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 107).isActive = true
        
        containerView.addSubview(emailTextField)
        emailTextField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 2).isActive = true
        emailTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12).isActive = true
        emailTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        containerView.addSubview(separatorTextField)
        separatorTextField.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        separatorTextField.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 2).isActive = true
        separatorTextField.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        containerView.addSubview(passwordTextField)
        passwordTextField.topAnchor.constraint(equalTo: separatorTextField.bottomAnchor, constant: 2).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: emailTextField.widthAnchor).isActive = true
        passwordTextField.centerXAnchor.constraint(equalTo: emailTextField.centerXAnchor).isActive = true
        passwordTextField.heightAnchor.constraint(equalTo: emailTextField.heightAnchor).isActive = true
        
        
        view.addSubview(registerButton)
        registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registerButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 8).isActive = true
        registerButton.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(switchAuthButton)
        switchAuthButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        switchAuthButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 4).isActive = true
        switchAuthButton.widthAnchor.constraint(equalTo: registerButton.widthAnchor).isActive = true
        switchAuthButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    @objc func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            self.showMessage(with: "Error", message: "An error occurred while retrieving your email address.")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if error != nil {
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    switch errCode {
                    case .emailAlreadyInUse:
                        print("Email already in use, attempting to login.")
                        self.handleLogin()
                    default:
                        guard let error = error else { return }
                        self.showMessage(with: "Error", message: error.localizedDescription)
                    }
                }
                
            }
            
            guard let result = authResult else {
                print("Something occured while signing up, perhaps user already has an account.")
                return
            }
            
            let userEmail = result.user.email
            let uid = result.user.uid
            
            UserDefaults.standard.setValue(userEmail, forKey: "email")
            UserDefaults.standard.setValue(uid, forKey: "uid")
            
            self.saveInDatabase(with: email, uid: uid)
        }
        
    }
    
    
    func saveInDatabase(with email: String, uid: String) {
        let dbRef = Database.database().reference()
        dbRef.child("users").child(uid).setValue(["email": email]) { (error, _) in
            if let error = error {
                self.showMessage(with: "Error", message: error.localizedDescription)
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            self.showMessage(with: "Error", message: "An error occurred while retrieving your email address.")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            if let error = error {
                self.showMessage(with: "Error", message: error.localizedDescription)
                return
            }
            
            guard let result = authResult else {
                print("Error while trying to login, perhaps user doesn't have an account.")
                return
            }
            
            // Login Success
            let userEmail = result.user.email
            UserDefaults.standard.setValue(userEmail, forKey: "email")
            
            self.dismiss(animated: true, completion: nil)
            
        }
    }
}
