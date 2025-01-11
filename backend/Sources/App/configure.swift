import Vapor
import Fluent
import FluentMongoDriver
import JWT

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    // register routes
    
    try app.databases.use(
        .mongo(connectionString: "mongodb+srv://snehaagar:stackschool123@bruineatdb.qromc.mongodb.net/database?retryWrites=true&w=majority&appName=bruineatdb"),
        as: .mongo
    )

    // register controller
    try app.register(collection: UsersController())
    app.jwt.signers.use(.hs256(key: "SECRETKEY"))
    try routes(app)
}