//
//  AppDelegate.swift
//  Movies
//
//  Created by SJI-GOA-79 on 16/12/22.
//

import UIKit
import Amplify
import AWSCognitoAuthPlugin
import AWSCognitoIdentityProvider
import AWSDataStorePlugin
import RealmSwift
import IQKeyboardManagerSwift

let userPoolID = "ap-northeast-1_7Cr2lQ0Fx"

@main
class AppDelegate: UIResponder, UIApplicationDelegate, AWSCognitoIdentityInteractiveAuthenticationDelegate {
    
    class func defaultUserPool() -> AWSCognitoIdentityUserPool {
        return AWSCognitoIdentityUserPool(forKey: userPoolID)!
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        

        do {
            let realm = try! Realm()
            try! realm.write {
                realm.deleteAll()
                try! realm.commitWrite()
            }
        } catch {
            print("error: \(error)")
        }
        
        LoginModal.shared.getMoviesData()
        
        confugureAmplify()
        
        setupCognitoUserPool()
        return true
    }
    
    func confugureAmplify() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure()
            print("Amplify configured successfully")
        } catch {
            print("An error occurred setting up Amplify: \(error)")
        }
        print("AuthService.shared.isSignedIn  1: \(AuthService.shared.isSignedIn)")
        
        AuthService.shared.signOutLocally()
                
        AuthService.shared.observeAuthEvents()
        AuthService.shared.fetchCurrentAuthSession()
        
//        if AuthService.shared.isSignedIn {
//            var loginVc = LoginViewController()
//            loginVc.signedInSuccessfully()
//        }
    }
    
    func setupCognitoUserPool() {
        let poolId: String = "ap-northeast-1_7Cr2lQ0Fx"
        let clientId: String = "2lfmmki2mto53necr3v5phg6v8"
        let clientSecret: String = "1rll1775tmp6scjdfo9r37cfvadi7veat8i190teqk03nji0v5n8"
        let region:AWSRegionType = .APNortheast1
        
        let serviceConfiguration:AWSServiceConfiguration = AWSServiceConfiguration(region: region, credentialsProvider: nil)
        
        let cognitoConfiguration:AWSCognitoIdentityUserPoolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: clientId, clientSecret: clientSecret, poolId: poolId)
        
        AWSCognitoIdentityUserPool.register(with: serviceConfiguration, userPoolConfiguration: cognitoConfiguration, forKey: userPoolID)
        
        let pool:AWSCognitoIdentityUserPool = AppDelegate.defaultUserPool()
        pool.delegate = self
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Movies")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

