//
//  SignupViewController.swift
//  Movies
//
//  Created by SJI-GOA-79 on 16/12/22.
//

import UIKit
import Amplify
import AWSCognitoAuthPlugin
import AWSMobileClientXCF

class SignupViewController: UIViewController{
    
    var didChecked = false
    
    @IBOutlet weak var signupNavLabel: UILabel!
    @IBOutlet weak var signupWithAppleButton: UIButton!
    @IBOutlet weak var signupWithFacebookButton: UIButton!
    @IBOutlet weak var signupWithGoogleButton: UIButton!
    @IBOutlet weak var deviderLabel: UILabel!
    @IBOutlet weak var requiredField: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var paswordLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var agreeLabel: UILabel!
    @IBOutlet weak var termsAndConditionsButton: UIButton!
    @IBOutlet weak var privacyPolicyButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    let userDetails = AuthService.shared.userDetails
    
    var user: AWSCognitoIdentityUser?
    var codeDeliveryDetails:AWSCognitoIdentityProviderCodeDeliveryDetailsType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        setupUI()
    }
    
    func setupUI(){
        passwordTextField.isSecureTextEntry = true
        signupButton.isEnabled = false
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    @IBAction func didTapBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func didTabSocialSignUpButton(_ sender: UIButton) {
        webSignUp()
        func webSignUp() {
            
            switch sender.restorationIdentifier {
            case "appleBtn":
                signUpWithWebUI(account: "apple")
                
            case "FBBtn":
                signUpWithWebUI(account: "facebook")
                
            case "googleBtn":
                signUpWithWebUI(account: "google")
            case .none:
                print("No button clicked")
            case .some(_):
                print("No button clicked")
            }
        }
    }
    
    @IBAction func didTapShowHideButton(_ sender: UIButton) {
        let showPW = UIImage(named: "show_password")
        let hidePW = UIImage(named: "hide_password")
        
        if sender.currentImage === showPW {
            print("show")
            sender.setImage(hidePW, for: .normal)
            passwordTextField.isSecureTextEntry = false
        }else {
            print("hide")
            sender.setImage(showPW, for: .normal)
            passwordTextField.isSecureTextEntry = true
        }
    }
    
    
    @IBAction func didTabSignupButton(_ sender: AnyObject) {
        
        let nameAttribute = AWSCognitoIdentityUserAttributeType(name: "name", value: "Test")
        let emailAttribute = AWSCognitoIdentityUserAttributeType(name: "email", value: emailTextField.text!)
        let passwordAttribute = AWSCognitoIdentityUserAttributeType(name: "custom:password", value: passwordTextField.text!)
        let attributes:[AWSCognitoIdentityUserAttributeType] = [nameAttribute,emailAttribute,passwordAttribute]
        
        let userPool = AppDelegate.defaultUserPool()
                
        userPool.signUp(emailTextField.text!, password: passwordTextField.text!, userAttributes: attributes, validationData: nil)
            .continueWith { (response) -> Any? in
                if response.error != nil {
                                        
                    let alert = UIAlertController(title: "Error", message: (response.error! as NSError).userInfo["message"] as? String, preferredStyle: .alert)
                    
                    DispatchQueue.main.async {
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                } else {
                    self.user = response.result!.user
                    // Does user need confirmation?
                    if (response.result?.userConfirmed?.intValue != AWSCognitoIdentityUserStatus.confirmed.rawValue) {
                        // User needs confirmation, so we need to proceed to the verify view controller
                        print("@@AWSCognitoIdentityUserStatus \(AWSCognitoIdentityUserStatus.confirmed)")
                        DispatchQueue.main.async {
                            self.codeDeliveryDetails = response.result?.codeDeliveryDetails
                        }
                    }
                    
                    print("@@SIGNED UP")
                    if (self.userDetails != nil) {
                        DispatchQueue.main.async {
                            
                            if let screen1VC = UIStoryboard.auth
                                .instantiateViewController(withIdentifier: "Screen1ViewController") as? Screen1ViewController {
                                
                                screen1VC.modalPresentationStyle = .fullScreen
                                self.navigationController?.navigationBar.topItem?.hidesBackButton = true
                                self.navigationItem.setHidesBackButton(true, animated: true)
                                self.navigationController?.navigationBar.isHidden = true
                                self.navigationController?.pushViewController(screen1VC, animated: true)
                            }
                        }
                    }
                }
                    
                return nil
            }
    }
    @IBAction func didTapCheckUncheckButton(_ sender: UIButton) {
        let checked = UIImage(named: "checked")
        let unchecked = UIImage(named: "unchecked")
        
        if sender.currentImage === checked {
            print("unchecked")
            agreeLabel.textColor = UIColor(hexaRGB: "#b3b3b3", alpha: 1)
            
            didChecked = false
            sender.setImage(unchecked, for: .normal)
            
            signupButton.isEnabled = false
            signupButton.setBackgroundImage(UIImage(named: "signup_button_inactive"), for: .normal)
            signupButton.setTitleColor(.black, for: .normal)
            
        }else {
            print("checked")
            agreeLabel.textColor = UIColor(hexaRGB: "#007ab7", alpha: 1)
            didChecked = true
            sender.setImage(checked, for: .normal)
            
            if emailTextField.text != "" && passwordTextField.text != "" {
                signupButton.isEnabled = true
                signupButton.setBackgroundImage(UIImage(named: "signup_button_ready"), for: .normal)
                signupButton.setTitleColor(.white, for: .normal)
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
            let email = emailTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty
        else {
            signupButton.isEnabled = false
            signupButton.setBackgroundImage(UIImage(named: "signup_button_inactive"), for: .normal)
            signupButton.setTitleColor(.black, for: .normal)
            return
        }
        if didChecked {
            signupButton.isEnabled = true
            signupButton.setBackgroundImage(UIImage(named: "signup_button_ready"), for: .normal)
            signupButton.setTitleColor(.white, for: .normal)
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
        
        if emailTextField.text != "" && passwordTextField.text != "" {
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
    
    
    func signUpWithWebUI(account: String) {
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


