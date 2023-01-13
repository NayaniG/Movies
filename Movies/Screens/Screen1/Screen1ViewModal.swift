//
//  Screen1ViewModal.swift
//  Movies
//
//  Created by SJI-GOA-79 on 22/12/22.
//

import Foundation
import RealmSwift

protocol MoviesManagerDelegate {
    func didFailWithError(error: Error)
}

struct MovieManager {
    
    static var shared = MovieManager()
    
    private init() {}
    
    var delegate: MoviesManagerDelegate?
    
    let items = List<Items>()
    
    private var dataTask: URLSessionDataTask?
    
    mutating func getTopMovies(completion: @escaping (MoviesData) -> Void) {
        
        let topMoviesUrl = APIConstants.Screen1URL
        
        guard let url = URL(string: topMoviesUrl) else {return}
        
        dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                print("DataTask error: \(error.localizedDescription)")
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print("Empty Response")
                return
            }
            print("Response status code: \(response.statusCode)")
            
            guard let data = data else {
                print("Empty Data")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(MoviesData.self, from: data)
                                                
                DispatchQueue.main.async {
                    completion(jsonData)
                    print("jsonData: \(jsonData)")
                }
            } catch let error {
                print(error)
            }
        }
        dataTask?.resume()
    }
    
    
    func getDisplayCount(currentCount: Int, moviesItemsCoutnt: Int) -> Int {
        print("@@currentCount: \(currentCount)")
        
        var displayCount = 0
        
        switch (currentCount)  {
        case 250:
            displayCount = moviesItemsCoutnt
            
        case 200:
            displayCount = moviesItemsCoutnt
            
        case 150:
            displayCount = moviesItemsCoutnt - 50
            
        case 100:
            displayCount = moviesItemsCoutnt - 100
            
        case 50:
            displayCount = moviesItemsCoutnt - 150
            
        case 0:
            displayCount = moviesItemsCoutnt - 200
            
        default:
            displayCount = moviesItemsCoutnt - 200
        }
        return displayCount
    }
    
}


