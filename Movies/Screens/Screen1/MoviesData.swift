//
//  MoviesData.swift
//  Movies
//
//  Created by SJI-GOA-79 on 22/12/22.
//

import Foundation
import RealmSwift

class MoviesData: Object, Decodable {
    var items = List<Items>()
}

class Items: Object, Decodable {
    @objc dynamic var  id: String?
    @objc dynamic var  title: String?
    @objc dynamic var  image: String?
    
    var parentCategory = LinkingObjects(fromType: MoviesData.self, property: "items")
    
    enum CodingKeys: String, CodingKey {
          case id
          case title
          case image
    }
}

