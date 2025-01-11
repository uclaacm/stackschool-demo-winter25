//
//  AppState.swift
//  BruinEatsApp
//
//  Created by Sneha Agarwal on 1/10/25.
//


import Foundation

enum Route: Hashable {
    case login
    case register
    case bruineatsList
}

class AppState: ObservableObject {
    @Published var routes: [Route] = []
}
