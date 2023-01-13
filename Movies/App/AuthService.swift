//
//  ViewController.swift
//  Movies
//
//  Created by SJI-GOA-79 on 16/12/22.
//

import Amplify
import AWSPluginsCore
import AuthenticationServices

class AuthService {
    
    static let shared = AuthService()
    let userDetails = Amplify.Auth.getCurrentUser()
    var isSignedIn = false
    let screen1Vc = Screen1ViewController()
    
    private init() {}
    
    func fetchCurrentAuthSession() {
        _ = Amplify.Auth.fetchAuthSession { [weak self] result in
            switch result {
            case .success(let session):
                DispatchQueue.main.async {
                    self?.isSignedIn = session.isSignedIn
                    print("Is signed in: \(self!.isSignedIn)")
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    var window: UIWindow {
        guard
            let scene = UIApplication.shared.connectedScenes.first,
            let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
            let window = windowSceneDelegate.window as? UIWindow
        else { return UIWindow() }
        
        return window
    }
    
    func observeAuthEvents() {
        _ = Amplify.Hub.listen(to: .auth) { [weak self] result in
            switch result.eventName {
            case HubPayload.EventName.Auth.signedIn:
                DispatchQueue.main.async {
                    self?.isSignedIn = true
                }
                
            case HubPayload.EventName.Auth.signedOut,
                 HubPayload.EventName.Auth.sessionExpired:
                DispatchQueue.main.async {
                    self?.isSignedIn = false
                }
                
            default:
                break
            }
        }
    }
    
    func signOutLocally() {
        Amplify.Auth.signOut() { result in
            switch result {
            case .success:
                print("Successfully signed out")
                self.observeAuthEvents()
                self.fetchCurrentAuthSession()
                
            case .failure(let error):
                print("Sign out failed with error \(error)")
            }
        }
    }
}

