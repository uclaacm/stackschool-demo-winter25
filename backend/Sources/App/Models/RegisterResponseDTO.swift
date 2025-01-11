//
//  RegisterResponseDTO.swift
//  bruineats-server-app
//
//  Created by Sneha Agarwal on 1/10/25.
//

import Foundation
import Vapor

struct RegisterResponseDTO: Content {
    let error: Bool
    var reason: String? = nil
}
