//
//  SignupViewController.swift
//  Movies
//
//  Created by SJI-GOA-79 on 16/12/22.
//

import UIKit
import Amplify
import AWSCognitoIdentityProvider
import AWSCognitoAuthPlugin
import AWSCognitoIdentityProviderASF

class SignupViewController: UIViewController{
    
    @IBOutlet weak var SignupView: SignupView!
    
    let userDetails = AuthService.shared.userDetails
    var user: AWSCognitoIdentityUser?
    var codeDeliveryDetails: AWSCognitoIdentityProviderCodeDeliveryDetailsType?
    var didChecked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SignupView.emailTextField.delegate = self
        SignupView.passwordTextField.delegate = self
        
        setupUI()
    }
    
    func setupUI(){
        SignupView.passwordTextField.isSecureTextEntry = true
        SignupView.signupButton.isEnabled = false
        SignupView.emailTextField.delegate = self
        SignupView.passwordTextField.delegate = self
    }
    
    @IBAction func didTapBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func didTabSocialSignUpButton(_ sender: UIButton) {
        
        switch sender.restorationIdentifier {
        case "appleBtn":
            webSignUpWithApple()
        case "FBBtn":
            webSignUpWithFacebook()
            
        case "googleBtn":
            webSignupWithGoogle()
        case .none:
            print("No button clicked")
        case .some(_):
            print("No button clicked")
        }
    }
    
    @IBAction func didTapShowHideButton(_ sender: UIButton) {
        let showPW = UIImage(named: "show_password")
        let hidePW = UIImage(named: "hide_password")
        
        if sender.currentImage === showPW {
            print("show")
            sender.setImage(hidePW, for: .normal)
            SignupView.passwordTextField.isSecureTextEntry = false
        }else {
            print("hide")
            sender.setImage(showPW, for: .normal)
            SignupView.passwordTextField.isSecureTextEntry = true
        }
    }
    
    
    @IBAction func didTabSignupButton(_ sender: AnyObject) {
        
        let nameAttribute = AWSCognitoIdentityUserAttributeType(name: "name", value: "Test")
        let emailAttribute = AWSCognitoIdentityUserAttributeType(name: "email", value: SignupView.emailTextField.text!)
        let passwordAttribute = AWSCognitoIdentityUserAttributeType(name: "custom:password", value: SignupView.passwordTextField.text!)
        let attributes:[AWSCognitoIdentityUserAttributeType] = [nameAttribute,emailAttribute,passwordAttribute]
        
        let userPool = AppDelegate.defaultUserPool()
        
        userPool.signUp(SignupView.emailTextField.text!, password: SignupView.passwordTextField.text!, userAttributes: attributes, validationData: nil)
            .continueWith { [self] (response) -> Any? in
                if response.error != nil {
                    
                    let alert = UIAlertController(title: "Error", message: (response.error! as NSError).userInfo["message"] as? String, preferredStyle: .alert)
                    
                    DispatchQueue.main.async {
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                } else {
                    self.user = response.result!.user

                    if (response.result?.userConfirmed?.intValue != AWSCognitoIdentityUserStatus.confirmed.rawValue) {

                        print("@@AWSCognitoIdentityUserStatus \(AWSCognitoIdentityUserStatus.confirmed)")
                        DispatchQueue.main.async {
                            self.codeDeliveryDetails = response.result?.codeDeliveryDetails
                        }
                    }
                    
                    print("@@SIGNED UP")
                    signedInSuccessfully()
                }
                
                return nil
            }
    }
    
    @IBAction func didTapCheckUncheckButton(_ sender: UIButton) {
        let checked = UIImage(named: "checked")
        let unchecked = UIImage(named: "unchecked")
        
        if sender.currentImage === checked {
            print("unchecked")
            SignupView.agreeLabel.textColor = UIColor(hexaRGB: "#b3b3b3", alpha: 1)
            
            didChecked = false
            sender.setImage(unchecked, for: .normal)
            
            SignupView.signupButton.isEnabled = false
            SignupView.signupButton.setBackgroundImage(UIImage(named: "signup_button_inactive"), for: .normal)
            SignupView.signupButton.setTitleColor(.black, for: .normal)
            
        }else {
            print("checked")
            SignupView.agreeLabel.textColor = UIColor(hexaRGB: "#007ab7", alpha: 1)
            didChecked = true
            sender.setImage(checked, for: .normal)
            
            if SignupView.emailTextField.text != "" && SignupView.passwordTextField.text != "" {
                SignupView.signupButton.isEnabled = true
                SignupView.signupButton.setBackgroundImage(UIImage(named: "signup_button_ready"), for: .normal)
                SignupView.signupButton.setTitleColor(.white, for: .normal)
            }
        }
    }
    
    func showValidationAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func enableSignupButton(_ textField: UITextField) {
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
        guard
            let email = SignupView.emailTextField.text, !email.isEmpty,
            let password = SignupView.passwordTextField.text, !password.isEmpty
        else {
            SignupView.signupButton.isEnabled = false
            SignupView.signupButton.setBackgroundImage(UIImage(named: "signup_button_inactive"), for: .normal)
            SignupView.signupButton.setTitleColor(.black, for: .normal)
            return
        }
        if didChecked {
            SignupView.signupButton.isEnabled = true
            SignupView.signupButton.setBackgroundImage(UIImage(named: "signup_button_ready"), for: .normal)
            SignupView.signupButton.setTitleColor(.white, for: .normal)
        }
    }
    
    func fieldValidation(_ textField: UITextField) {
        if textField.restorationIdentifier == "email" {
            
            let validEmail = isValidEmail(textField.text!)
            
            if textField.text == "" || !validEmail {
                showValidationAlert(title: "Invalid Email", message: "Please enter Email in the valid format")
            }
            
        } else if textField.restorationIdentifier == "password" {
            
            let validpassword = isValidPassword(textField.text!)
            
            if textField.text == "" || !validpassword {
                showValidationAlert(title: "Invalid Password", message: "Password must have at least 8 letters, containing at least 1 special character and 1 number")
            }
        }
        
        if SignupView.emailTextField.text != "" && SignupView.passwordTextField.text != "" {
            if !didChecked {
                let alert = UIAlertController(title: "", message: "Please agree to our terms & condition and privacy policy by checking ‘Agree", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
                return
            }
        }
        
        func isValidEmail(_ email: String) -> Bool {
            let emailRegEx = String().emailRegEx
            
            let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailPred.evaluate(with: email)
        }
        
        func isValidPassword(_ password: String) -> Bool {
            let passwordRegEx = String().passwordRegEx
            
            let passwordPred = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
            return passwordPred.evaluate(with: password)
        }
    }
    
    func webSignUpWithApple() {
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
    
    func webSignUpWithFacebook() {
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

    func webSignupWithGoogle() {
                
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
    
    func signedInSuccessfully() {
        print("Signed in successfully")
        
        AuthService.shared.observeAuthEvents()
        AuthService.shared.fetchCurrentAuthSession()
        
        DispatchQueue.main.async {
            
            if let screen1VC = UIStoryboard.auth
                .instantiateViewController(withIdentifier: "Screen1ViewController") as? Screen1ViewController {
                
                screen1VC.modalPresentationStyle = .fullScreen
                self.navigationItem.setHidesBackButton(true, animated: true)
                self.navigationController?.navigationBar.isHidden = true
                self.navigationController?.pushViewController(screen1VC, animated: true)
            }
        }
    }
    
}

extension SignupViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        print("textFieldDidEndEditing")
        fieldValidation(textField)
        enableSignupButton(textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        print("textFieldShouldReturn")
        fieldValidation(textField)
        enableSignupButton(textField)
        return true
    }
}
