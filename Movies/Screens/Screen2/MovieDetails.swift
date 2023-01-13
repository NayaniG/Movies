//
//  MovieDeatils.swift
//  Movies
//
//  Created by SJI-GOA-79 on 27/12/22.
//

import Foundation
import RealmSwift

class MoviesDetails: Object, Decodable {
    var title: String?
    var image: String?
    var imDbRating: String?
    var releaseDate: String?
    var plot: String?
    var actorList = List<Actors>()
}

class Actors: Object, Decodable {
    @objc dynamic var image: String?
    @objc dynamic var name: String?
    
    var parentCategory = LinkingObjects(fromType: MoviesDetails.self, property: "actorList")
    
    enum CodingKeys: String, CodingKey {
          case image
          case name
    }
}
