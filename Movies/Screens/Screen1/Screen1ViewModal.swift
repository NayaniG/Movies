//
//  Screen1ViewModal.swift
//  Movies
//
//  Created by SJI-GOA-79 on 22/12/22.
//

import Foundation

protocol MoviesManagerDelegate {
    func didUpdateMovies(movies: MoviesModal)
    func didFailWithError(error: Error)
}

struct MovieManager {
    
    static var sharedObj = MovieManager()
    
    var delegate: MoviesManagerDelegate?
    
    let baseURL = "https://imdb-api.com/en/API/Top250Movies/k_pzptd5zy"
    
    func getMovies(onSucess: @escaping([Items]) -> Void) {
        
        let urlString = "\(baseURL)"
        
        if let url = URL(string: urlString) {
            print("URL: \(url)")
                                    
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
     
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    let decoder = JSONDecoder()
                    do {
                        let decodedData = try decoder.decode(MoviesData.self, from: data!)
                        onSucess(decodedData.items!)
                    } catch {
                        delegate?.didFailWithError(error: error)
                    }
                }
            }
            task.resume()
        }
    }
}
