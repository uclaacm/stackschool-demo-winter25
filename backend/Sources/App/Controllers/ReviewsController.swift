//
//  ReviewsController.swift
//  bruineats-server-app
//
//  Created by Samuel Perrott on 24/01/25.
//
import Foundation
import Vapor
import Fluent
import FluentMongoDriver

// ReviewsController.swift
class ReviewsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let api = routes.grouped("api")
        let protected = api.grouped(JWTAuthenticator())
        
        // GET /api/reviews?restaurantId=xyz
        api.get("reviews", use: index)
        // POST /api/reviews
        protected.post("reviews", use: create)
    }
    
    func index(req: Request) async throws -> [Review] {
        guard let restaurantId = req.query[UUID.self, at: "restaurantId"] else {
            throw Abort(.badRequest)
        }
        
        return try await Review.query(on: req.db)
            .filter(\.$restaurant.$id == restaurantId)
            .with(\.$user)  // Eager load user data
            .all()
    }
    
    func create(req: Request) async throws -> Review {
        let userId = try req.auth.require(AuthPayload.self).userId
        let reviewDTO = try req.content.decode(ReviewRequestDTO.self)
        
        let review = Review(
            rating: reviewDTO.rating,
            comment: reviewDTO.comment,
            userId: userId,
            restaurantId: reviewDTO.restaurantId
        )
        
        try await review.save(on: req.db)
        
        // Update restaurant average rating
        let reviews = try await Review.query(on: req.db)
            .filter(\.$restaurant.$id == reviewDTO.restaurantId)
            .all()
        
        let avgRating = Double(reviews.map { $0.rating }.reduce(0, +)) / Double(reviews.count)
        
        guard let restaurant = try await Restaurant.find(reviewDTO.restaurantId, on: req.db) else {
            throw Abort(.notFound)
        }
        restaurant.averageRating = avgRating
//        try await restaurant.save(on: req.db)
//
//        return review
        try await restaurant.save(on: req.db)
        
        return try await Review.query(on: req.db)
            .filter(\.$id == review.id!)
            .with(\.$user)
//            .with(\.$restaurant)
            .first() ?? review

    }
}
