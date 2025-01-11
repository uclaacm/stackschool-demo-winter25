//
//  RegisterResponseDTO.swift
//  BruinEatsApp
//
//  Created by Sneha Agarwal on 1/10/25.
//

import Foundation

struct RegisterResponseDTO: Codable {
    let error: Bool
    var reason: String? = nil
}
