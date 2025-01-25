//import Foundation
//
//class BruinEatsModel: ObservableObject {
//    @Published var restaurants: [Restaurant] = []
//    @Published var reviews: [Review] = []
//    @Published private var appState = AppState()
//
//    let decoder: JSONDecoder = {
//        let decoder = JSONDecoder()
//        decoder.dateDecodingStrategy = .iso8601
//        return decoder
//    }()
//
//    let httpClient = HTTPClient()
//
//
//    func register(username: String, password: String) async throws -> RegisterResponseDTO {
//        
//        let registerData = ["username": username, "password": password]
//        let resource = try Resource(url: Constants.Urls.register, method: .post(JSONEncoder().encode(registerData)), modelType: RegisterResponseDTO.self)
//        let registerResponseDTO = try await httpClient.load(resource)
//        return registerResponseDTO
//    }
//    
//    func login(username: String, password: String) async throws -> LoginResponseDTO {
//        
//        let loginPostData = ["username": username, "password": password]
//        
//        // resource
//        let resource = try Resource(url: Constants.Urls.login, method: .post(JSONEncoder().encode(loginPostData)), modelType: LoginResponseDTO.self)
//        
//        let loginResponseDTO = try await httpClient.load(resource)
//        
//        if !loginResponseDTO.error && loginResponseDTO.token != nil && loginResponseDTO.userId != nil {
//            // save the token in user defaults
//            let defaults = UserDefaults.standard
//            defaults.set(loginResponseDTO.token!, forKey: "authToken")
//            defaults.set(loginResponseDTO.userId!.uuidString, forKey: "userId")
//            await MainActor.run {
//                appState.isAuthenticated = true
//                Task {
//                            try? await fetchRestaurants()
//                        }
//
//            }
//            
//
//        }
//
//        return loginResponseDTO
//    }
//    func signOut() {
//        UserDefaults.standard.removeObject(forKey: "authToken")
//        UserDefaults.standard.removeObject(forKey: "userId")
//        restaurants = []
//        reviews = []
//    }
//
//    func addRestaurant(name: String, description: String, imageUrl: String?) async throws -> Restaurant {
//        let restaurantData = RestaurantRequestDTO(name: name, description: description, imageUrl: imageUrl)
//        let resource = try Resource(url: Constants.Urls.restaurants,
//                                  method: .post(JSONEncoder().encode(restaurantData)),
//                                  modelType: Restaurant.self)
//        let restaurant = try await httpClient.load(resource)
//        restaurants.append(restaurant)
//        return restaurant
//    }
//    
//    func fetchRestaurants() async throws {
//        let resource = Resource(url: Constants.Urls.restaurants,
//                              method: .get([]),
//                              modelType: [Restaurant].self)
//        restaurants = try await httpClient.load(resource)
//    }
//    
//    func fetchReviews(for restaurantId: UUID) async throws {
//        let queryItems = [URLQueryItem(name: "restaurantId", value: restaurantId.uuidString)]
//        let resource = Resource(url: Constants.Urls.reviews,
//                              method: .get(queryItems),
//                              modelType: [Review].self)
//        reviews = try await httpClient.load(resource)
//    }
//    
//    func addReview(restaurantId: UUID, rating: Int, comment: String) async throws -> Review {
//        let reviewData = ReviewRequestDTO(restaurantId: restaurantId, rating: rating, comment: comment)
//        let resource = try Resource(url: Constants.Urls.reviews,
//                                  method: .post(JSONEncoder().encode(reviewData)),
//                                  modelType: Review.self)
//        let review = try await httpClient.load(resource)
//        await MainActor.run {
//            reviews.append(review)
//            reviews.sort { $0.createdAt > $1.createdAt }  // Optional: sort by date
//        }
//        return review
//        
//    }
//    
//}
import Foundation
import SwiftUI

class BruinEatsModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    @Published var reviewsByRestaurant: [UUID: [Review]] = [:]
    @Published private var appState = AppState()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    private let httpClient = HTTPClient()

    // MARK: - User Authentication

    func register(username: String, password: String) async throws -> RegisterResponseDTO {
        let registerData = ["username": username, "password": password]
        let resource = try Resource(
            url: Constants.Urls.register,
            method: .post(JSONEncoder().encode(registerData)),
            modelType: RegisterResponseDTO.self
        )
        return try await httpClient.load(resource)
    }

    func login(username: String, password: String) async throws -> LoginResponseDTO {
        let loginPostData = ["username": username, "password": password]
        let resource = try Resource(
            url: Constants.Urls.login,
            method: .post(JSONEncoder().encode(loginPostData)),
            modelType: LoginResponseDTO.self
        )

        let loginResponseDTO = try await httpClient.load(resource)

        if !loginResponseDTO.error,
           let token = loginResponseDTO.token,
           let userId = loginResponseDTO.userId {
            // Save the token and userId in UserDefaults
            let defaults = UserDefaults.standard
            defaults.set(token, forKey: "authToken")
            defaults.set(userId.uuidString, forKey: "userId")
            
            await MainActor.run {
                appState.isAuthenticated = true
            }

            // Fetch restaurants upon login
            try? await fetchRestaurants()
        }

        return loginResponseDTO
    }

    func signOut() {
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "userId")
        
        // Clear local data
        DispatchQueue.main.async {
            self.restaurants = []
            self.reviewsByRestaurant = [:]
        }
    }

    // MARK: - Restaurant Management

    func addRestaurant(name: String, description: String, imageUrl: String?) async throws -> Restaurant {
        let restaurantData = RestaurantRequestDTO(name: name, description: description, imageUrl: imageUrl)
        let resource = try Resource(
            url: Constants.Urls.restaurants,
            method: .post(JSONEncoder().encode(restaurantData)),
            modelType: Restaurant.self
        )
        let restaurant = try await httpClient.load(resource)
        
        await MainActor.run {
            self.restaurants.append(restaurant)
        }
        return restaurant
    }

    func fetchRestaurants() async throws {
        let resource = Resource(
            url: Constants.Urls.restaurants,
            method: .get([]),
            modelType: [Restaurant].self
        )
        let fetchedRestaurants = try await httpClient.load(resource)
        
        await MainActor.run {
            self.restaurants = fetchedRestaurants
        }
    }

    // MARK: - Reviews Management

    func fetchReviews(for restaurantId: UUID) async throws {
        let queryItems = [URLQueryItem(name: "restaurantId", value: restaurantId.uuidString)]
        let resource = Resource(
            url: Constants.Urls.reviews,
            method: .get(queryItems),
            modelType: [Review].self
        )
        let fetchedReviews = try await httpClient.load(resource)

        await MainActor.run {
            self.reviewsByRestaurant[restaurantId] = fetchedReviews
        }
    }

    func addReview(restaurantId: UUID, rating: Int, comment: String) async throws -> Review {
        let reviewData = ReviewRequestDTO(restaurantId: restaurantId, rating: rating, comment: comment)
        let resource = try Resource(
            url: Constants.Urls.reviews,
            method: .post(JSONEncoder().encode(reviewData)),
            modelType: Review.self
        )
        let review = try await httpClient.load(resource)
        
        await MainActor.run {
            // Add the new review and sort by date
            if self.reviewsByRestaurant[restaurantId] != nil {
                self.reviewsByRestaurant[restaurantId]?.append(review)
                self.reviewsByRestaurant[restaurantId]?.sort { $0.createdAt > $1.createdAt }
            } else {
                self.reviewsByRestaurant[restaurantId] = [review]
            }
        }
        return review
    }
}
