//
//  RestaurantRequestDTO.swift
//  bruineats-server-app
//
//  Created by Samuel Perrott on 24/01/25.
//

import Foundation
import Vapor
// RestaurantRequestDTO.swift
struct RestaurantRequestDTO: Content {
    let name: String
    let description: String
    let imageUrl: String?
}





