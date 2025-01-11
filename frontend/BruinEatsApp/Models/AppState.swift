import Foundation

enum Route: Hashable {
    case login
    case register
    case bruineatsList
}

class AppState: ObservableObject {
    @Published var routes: [Route] = []
}
