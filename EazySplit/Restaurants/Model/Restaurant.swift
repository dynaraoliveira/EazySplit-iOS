//
//  Restaurant.swift
//  EazySplit
//
//  Created by Dynara Rico Oliveira on 21/04/19.
//  Copyright © 2019 Dynara Rico Oliveira. All rights reserved.
//

import Foundation

struct Restaurant: Codable {
    let id: Int
    let name: String
    let image: String
    let type: String
    let description: String
    let rating: Int
}

struct RestaurantList: Codable {
    var data: [Restaurant]?
    
    enum CodingKeys: String, CodingKey {
        case data
    }
}
