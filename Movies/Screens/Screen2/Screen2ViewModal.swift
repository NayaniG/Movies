//
//  Screen2ViewModal.swift
//  Movies
//
//  Created by SJI-GOA-79 on 27/12/22.
//

import Foundation


protocol MoviesDetailsDelegate {
    func didFailWithError(error: Error)
}

struct MovieDetailsManager {
    
    static var shared = MovieDetailsManager()
    
    var delegate: MoviesDetailsDelegate?
    
    let baseURL = APIConstants.Screen2URL
    
    func getMovieDetails(movieId: String, onSucess: @escaping(MoviesDetails) -> Void) {
        
        let urlString = "\(baseURL)\(movieId)"
        
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
                        let decodedData = try decoder.decode(MoviesDetails.self, from: data!)
                        onSucess(decodedData)
                    } catch {
                        delegate?.didFailWithError(error: error)
                    }
                }
            }
            task.resume()
        }
    }
}
