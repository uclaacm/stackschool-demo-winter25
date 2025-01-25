//
//  ReviewResponseDTO.swift
//  bruineats-server-app
//
//  Created by Samuel Perrott on 24/01/25.
//

import Foundation
import Vapor
// ReviewResponseDTO.swift
struct ReviewResponseDTO: Content {
    let id: UUID
    let rating: Int
    let comment: String
//    let userId: UUID
//    let restaurantId: UUID
    let createdAt: Date?
    
    let user: User
    let restaurant: Restaurant

    struct User: Content {
        let id: UUID
        let username: String
    }
    
    struct Restaurant: Content {
        let id: UUID
    }
}
