//
//  RestaurantsController.swift
//  bruineats-server-app
//
//  Created by Samuel Perrott on 24/01/25.
//

import Foundation
import Vapor
import Fluent
import FluentMongoDriver

// RestaurantsController.swift
class RestaurantsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let api = routes.grouped("api")
        let protected = api.grouped(JWTAuthenticator())
        
        // GET /api/restaurants
        api.get("restaurants", use: index)
        // POST /api/restaurants 
        protected.post("restaurants", use: create)
    }
    
    func index(req: Request) async throws -> [Restaurant] {
        try await Restaurant.query(on: req.db).all()
    }
    
    func create(req: Request) async throws -> Restaurant {
        let userId = try req.auth.require(AuthPayload.self).userId
        let restaurantDTO = try req.content.decode(RestaurantRequestDTO.self)
        
        let restaurant = Restaurant(
            name: restaurantDTO.name,
            description: restaurantDTO.description,
            imageUrl: restaurantDTO.imageUrl,
            userId: userId
        )
        
        try await restaurant.save(on: req.db)
        return restaurant
    }
}
