import Foundation
import Vapor
import Fluent
import FluentMongoDriver

class UsersController: RouteCollection {
    // /api/register
    // /api/login
    func boot(routes: RoutesBuilder) throws {
        let api = routes.grouped("api")
        
        // /api/register
        api.post("register", use: register)
        
        // api/login
        api.post("login", use: login)
    }
    
    func login(req: Request) async throws -> LoginResponseDTO {
        // decode the request
        let user = try req.content.decode(User.self)
        
        guard let existingUser = try await User.query(on: req.db)
            .filter(\.$username == user.username)
            .first() else {
            return LoginResponseDTO(error: true, reason: "Username is not found.")
        }
        
        // validate the password
        let result = try await req.password.async.verify(user.password, created: existingUser.password)
        
        if !result {
            return LoginResponseDTO(error: true, reason: "Password is incorrect.")
        }
        
        //generate the token and return it to the user
        let authPayload = try AuthPayload(
            expiration: .init(value: Date.distantFuture),
            userId: existingUser.requireID()
        )
        return try LoginResponseDTO(error: false, token: req.jwt.sign(authPayload), userId: existingUser.requireID())
    }
    
    func register(req: Request) async throws -> RegisterResponseDTO {
        
        // validate the user // validations
        try User.validate(content: req)
        let user = try req.content.decode(User.self)
        
        // find if the user already exists using the username
        if let _ = try await User.query(on: req.db)
            .filter(\.$username == user.username)
            .first() {
            throw Abort(.conflict, reason: "Username is already taken.")
        }
        // has the password
        user.password = try await req.password.async.hash(user.password)
        //save the user to the database
        try await user.save(on: req.db)
        return RegisterResponseDTO(error: false)
    }
}
