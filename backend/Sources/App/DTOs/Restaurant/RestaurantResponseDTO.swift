//
//  RestaurantResponseDTO.swift
//  bruineats-server-app
//
//  Created by Samuel Perrott on 24/01/25.
//

import Foundation
import Vapor
// RestaurantResponseDTO.swift
struct RestaurantResponseDTO: Content {
    let id: UUID
    let name: String
    let description: String
    let imageUrl: String?
    let averageRating: Double
    let userId: UUID
    let createdAt: Date?
}
