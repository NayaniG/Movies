//
//  LoginViewController.swift
//  Movies
//
//  Created by SJI-GOA-79 on 16/12/22.
//

import UIKit
import Amplify
import AWSCognitoIdentityProvider
import AWSCognitoAuthPlugin

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var signinWithAppleButton: UIButton!
    @IBOutlet weak var loginWithFacebook: UIButton!
    @IBOutlet weak var loginWithGoogleButton: UIButton!
    @IBOutlet weak var deviderLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var paswordLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButtonLoverlay: UIView!
    let userDetails = AuthService.shared.userDetails
        
    override func viewDidLoad() {
        super.viewDidLoad()
        AuthService.shared.signOutLocally()
        AuthService.shared.fetchCurrentAuthSession()
        setupUI()
    }
    
    func setupUI(){
        passwordTextField.isSecureTextEntry = true
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        print("@@AWSCognitoIdentityUserStatus \(AWSCognitoIdentityUserStatus.confirmed)")
        
                
        if userDetails != nil {
            
            if let screen1VC = UIStoryboard.auth
                .instantiateViewController(withIdentifier: "Screen1ViewController") as? Screen1ViewController {
                screen1VC.modalPresentationStyle = .fullScreen
                self.navigationItem.setHidesBackButton(true, animated: true)
                self.navigationController?.navigationBar.isHidden = true
                self.navigationController?.pushViewController(screen1VC, animated: true)
            }
        }
    }
    
    @IBAction func didTapSignUpButton(_ sender: UIButton) {
        
        print("TAPPED")
        
        if let signVupC = UIStoryboard.auth
            .instantiateViewController(withIdentifier: "SignupViewController") as? SignupViewController {
            signVupC.modalPresentationStyle = .fullScreen
            self.navigationController?.navigationBar.topItem?.hidesBackButton = true
            navigationController?.pushViewController(signVupC, animated: true)
        }
    }
    
    @IBAction func didTapShowHideButton(_ sender: UIButton) {
        let showPW = UIImage(named: "show_password")
        let hidePW = UIImage(named: "hide_password")
        
        if sender.currentImage === showPW {
            print("show")
            sender.setImage(hidePW, for: .normal)
            self.passwordTextField.isSecureTextEntry = false
        }else {
            print("hide")
            sender.setImage(showPW, for: .normal)
            self.passwordTextField.isSecureTextEntry = true
        }
    }
    
    @IBAction func didTapSocialSignin(_ sender: UIButton) {
        print("\(sender.restorationIdentifier ?? "button clicked") clicked")
        
            switch sender.restorationIdentifier {
            case "appleButton":
                signInWithWebUI(account: "apple")
                
            case "FBButton":
                signInWithWebUI(account: "facebook")
                
            case "googleButton":
                signInWithWebUI(account: "google")
                
            case .none:
                print("No button clicked")
            case .some(_):
                print("No button clicked")
            }
    }
    
    @IBAction func didTapLoginButton(_ sender: UIButton) {
        
        print("didTapLoginButton")
        
        signInWithEmail(email: emailTextField.text!, password: passwordTextField.text!)
        
        func signInWithEmail(email: String, password: String){
            let username = email
            _ = Amplify.Auth.signIn(username: username, password: password) {result in
                
                switch result {
                case .success(let SigninResult) :
                    print("@@SigninResult: \(SigninResult)")
                    
                    Amplify.Auth.fetchAuthSession { [self] result in
                        do {
                            let session = try result.get()
                            // It is false if the session has expired.
                            print("@@Is signed in: \(session.isSignedIn)")
                            
                                DispatchQueue.main.async {
                                    
                                    if let screen1VC = UIStoryboard.auth
                                        .instantiateViewController(withIdentifier: "Screen1ViewController") as? Screen1ViewController {
                                        
                                        screen1VC.modalPresentationStyle = .fullScreen
                                        self.navigationItem.setHidesBackButton(true, animated: true)
                                        self.navigationController?.navigationBar.isHidden = true
                                        self.navigationController?.pushViewController(screen1VC, animated: true)
                                    }
                                }
                            
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                case .failure(let error) :
                    print("Error: \(error)")
                    
                    let alert = UIAlertController(title: "Error", message: error.errorDescription, preferredStyle: .alert)
                    
                    DispatchQueue.main.async {
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    
    func signInWithWebUI(account: String) {
        _ = Amplify.Auth.signInWithWebUI(for: AuthProvider.custom(account), presentationAnchor: self.view.window!) { result in
            switch result {
            case .success:
                print("Signed in")
                
            case .failure(let error):
                print(error)
            }
        }
    }
}


extension LoginViewController: UITextViewDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        print("textFieldDidEndEditing")
        fieldValidation(textField)
        enableLoginButton(textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        print("textFieldShouldReturn")
        
        fieldValidation(textField)
        enableLoginButton(textField)
        return true
    }
    
    func fieldValidation(_ textField: UITextField) {
        if textField.text == "" {
            if textField.restorationIdentifier == "email" {
                showValidationAlert(title: "Please Enter Email", message: "Email cannot be blank")
            } else {
                showValidationAlert(title: "Please Enter Password", message: "Password cannot be blank")
            }
        }
    }
    
    func showValidationAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    @objc func enableLoginButton(_ textField: UITextField) {
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
            }
        }
        guard
            let email = self.emailTextField.text, !email.isEmpty,
            let password = self.passwordTextField.text, !password.isEmpty
        else {
            self.loginButton.setTitleColor(.black, for: .normal)
            self.loginButton.setBackgroundImage(UIImage(named: "login_button_inactive"), for: .normal)
            loginButtonLoverlay.isHidden = false
            
            return
        }
        self.loginButton.setBackgroundImage(UIImage(named: "login_button_ready"), for: .normal)
        self.loginButton.setTitleColor(.white, for: .normal)
        loginButtonLoverlay.isHidden = true
    }
}
