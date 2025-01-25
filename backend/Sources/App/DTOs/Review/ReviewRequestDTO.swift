//
//  ReviewRequestDTO.swift
//  bruineats-server-app
//
//  Created by Samuel Perrott on 24/01/25.
//

import Foundation
import Vapor
// ReviewRequestDTO.swift
struct ReviewRequestDTO: Content {
    let restaurantId: UUID
    let rating: Int
    let comment: String
}
