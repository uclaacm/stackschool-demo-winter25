//
//  LoginResponseDTO.swift
//  BruinEatsApp
//
//  Created by Sneha Agarwal on 1/10/25.
//

import Foundation

struct LoginResponseDTO: Codable {
    let error: Bool
    var reason: String? = nil
    var token: String? = nil
    var userId: UUID? = nil
}
