//
//  MoviesData.swift
//  Movies
//
//  Created by SJI-GOA-79 on 22/12/22.
//

import Foundation

struct MoviesData: Decodable {
    var items: [Items]?
}

struct Items: Decodable {
    var id: String?
    var title: String?
    var image: String?
}
