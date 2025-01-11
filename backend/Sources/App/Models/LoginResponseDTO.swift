//
//  LoginResponseDTO.swift
//  bruineats-server-app
//
//  Created by Sneha Agarwal on 1/10/25.
//

import Foundation
import Vapor

struct LoginResponseDTO: Content {
    let error: Bool
    var reason: String? = nil
    var token: String? = nil
    var userId: UUID? = nil
}
