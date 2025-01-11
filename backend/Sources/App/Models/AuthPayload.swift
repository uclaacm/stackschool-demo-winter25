//
//  AuthPayload.swift
//  bruineats-server-app
//
//  Created by Sneha Agarwal on 1/10/25.
//

import Foundation
import JWT

struct AuthPayload: JWTPayload {
    typealias Payload = AuthPayload
    
    enum CodingKeys: String, CodingKey {
        case expiration = "exp"
        case userId = "uid"
    }
    
    var expiration: ExpirationClaim
    var userId: UUID
    
    func verify(using signer: JWTSigner) throws {
        try self.expiration.verifyNotExpired()
    }
}
