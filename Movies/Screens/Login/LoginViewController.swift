//
//  LoginViewController.swift
//  Movies
//
//  Created by SJI-GOA-79 on 16/12/22.

import UIKit
import Amplify
import AWSCognitoIdentityProvider
import AWSCognitoAuthPlugin

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginView: LoginView!
    let screen1VC = Screen1ViewController()
    var authStatus = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AuthService.shared.signOutLocally()
        
        AuthService.shared.observeAuthEvents()
        print("AuthService.shared.isSignedIn  2: \(AuthService.shared.isSignedIn)")
        
        authStatus = AuthService.shared.isSignedIn
        
        if authStatus {
            signedInSuccessfully()
        }
        
        setupUI()
    }
    
    func setupUI(){
        loginView.passwordTextField.isSecureTextEntry = true
        loginView.emailTextField.delegate = self
        loginView.passwordTextField.delegate = self
        loginView.spinner.isHidden = true
        
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
            loginView.passwordTextField.isSecureTextEntry = false
        }else {
            print("hide")
            sender.setImage(showPW, for: .normal)
            loginView.passwordTextField.isSecureTextEntry = true
        }
    }
    
    @IBAction func didTapSocialSignin(_ sender: UIButton) {
        
        print("\(sender.restorationIdentifier ?? "button clicked")")
        
        switch sender.restorationIdentifier {
        case "appleButton":
            webSignInWithApple()
            
        case "FBButton":
            webSignInWithFacebook()
            
        case "googleButton":
            
            webSignInWithGoogle()
            
            
        case .none:
            print("No button clicked")
        case .some(_):
            print("No button clicked")
        }
    }
    
    
    func webSignInWithApple() {
        _ = Amplify.Auth.signInWithWebUI(for: .apple, presentationAnchor: AuthService.shared.window) { [self] result in
            switch result {
            case .success:
                print("Signed in with apple")
                signedInSuccessfully()
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func webSignInWithFacebook() {
        _ = Amplify.Auth.signInWithWebUI(for: .facebook, presentationAnchor: AuthService.shared.window) { [self] result in
            switch result {
            case .success:
                print("Signed in with facebook")
                signedInSuccessfully()
                
            case .failure(let error):
                print(error)
            }
        }
    }

    func webSignInWithGoogle() {
        _ = Amplify.Auth.signInWithWebUI(for: .google, presentationAnchor: AuthService.shared.window) { [self] result in
            switch result {
            case .success:
                print("Signed in with google")
                signedInSuccessfully()
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func didTapLoginButton(_ sender: UIButton) {
        
        print("didTapLoginButton")
        
        signInWithEmail(email: loginView.emailTextField.text!, password: loginView.passwordTextField.text!)
        
        func signInWithEmail(email: String, password: String){
            loginView.spinner.isHidden = false
            loginView.spinner.startAnimating()
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
                            signedInSuccessfully()
                            
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
    
    func signedInSuccessfully() {
        print("Signed in successfully")
        DispatchQueue.main.async {
            
            if let screen1VC = UIStoryboard.auth
                .instantiateViewController(withIdentifier: "Screen1ViewController") as? Screen1ViewController {
                
                screen1VC.modalPresentationStyle = .fullScreen
                self.navigationItem.setHidesBackButton(true, animated: true)
                self.navigationController?.navigationBar.isHidden = true
                self.navigationController?.pushViewController(screen1VC, animated: true)
                self.loginView.spinner.isHidden = true
                self.loginView.spinner.stopAnimating()
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
            let email = loginView.emailTextField.text, !email.isEmpty,
            let password = loginView.passwordTextField.text, !password.isEmpty
        else {
            loginView.loginButton.setTitleColor(.black, for: .normal)
            loginView.loginButton.setBackgroundImage(UIImage(named: "login_button_inactive"), for: .normal)
            loginView.loginButtonLoverlay.isHidden = false
            
            return
        }
        loginView.loginButton.setBackgroundImage(UIImage(named: "login_button_ready"), for: .normal)
        loginView.loginButton.setTitleColor(.white, for: .normal)
        loginView.loginButtonLoverlay.isHidden = true
    }
}


