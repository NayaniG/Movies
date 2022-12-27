//
//  ViewController.swift
//  Movies
//
//  Created by SJI-GOA-79 on 16/12/22.
//

import Combine
import Amplify
import AWSPluginsCore
import AWSMobileClientXCF

class AuthService {
    
    static let shared = AuthService()
    let userDetails = Amplify.Auth.getCurrentUser()
    private init() {}
    
    func fetchCurrentAuthSession() {
        
        Amplify.Auth.fetchAuthSession { result in
            do {
                let session = try result.get()
                
                // It is false if the session has expired.
                print("Is signed in: \(session.isSignedIn)")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func signOutLocally() {
        Amplify.Auth.signOut() { result in
            switch result {
            case .success:
                print("Successfully signed out")
                
            case .failure(let error):
                print("Sign out failed with error \(error)")
            }
        }
    }
}

