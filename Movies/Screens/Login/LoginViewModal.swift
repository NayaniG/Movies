//
//  LoginViewModal.swift
//  Movies
//
//  Created by SJI-GOA-79 on 12/01/23.
//

import RealmSwift

class LoginModal {
    
    static let shared = LoginModal()
    private init() {}
    
    let realm = try! Realm()
    var moviesData = MoviesData()
    
    func getMoviesData() {
        MovieManager.shared.getTopMovies { [self] result in
            self.moviesData = result
            
            do {
                try! realm.write {
                    realm.add(moviesData)
                    let fetchData = try! realm.objects(MoviesData.self)
                    print("fetchData: \(fetchData)")
                    try! realm.commitWrite()
                }
            } catch {
                print("error: \(error)")
            }
        }
    }
    
}

