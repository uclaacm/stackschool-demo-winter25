//
//  Restaurant.swift
//  BruinEatsApp
//
//  Created by Samuel Perrott on 24/01/25.
//

import Foundation

struct Restaurant: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String
    let imageUrl: String?
    let createdAt: Date
    let averageRating: Double
    let user: User
    
    struct User: Codable {
        let id: UUID
    }
}

struct Review: Codable, Identifiable {
    let id: UUID
    let rating: Int
    let comment: String
    let createdAt: Date
    let user: User
    let restaurant: Restaurant
    
    struct User: Codable {
        let id: UUID
        let username: String
        let password: String

    }
    
    struct Restaurant: Codable {
        let id: UUID
    }
}

// DTOs
struct RestaurantRequestDTO: Codable {
    let name: String
    let description: String
    let imageUrl: String?
}

struct ReviewRequestDTO: Codable {
    let restaurantId: UUID
    let rating: Int
    let comment: String
}
