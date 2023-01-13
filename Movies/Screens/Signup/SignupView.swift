//
//  SignupView.swift
//  Movies
//
//  Created by SJI-GOA-79 on 12/01/23.
//

import UIKit

class SignupView: UIView {
    
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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
