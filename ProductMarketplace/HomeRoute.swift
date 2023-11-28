import Foundation
enum HomeRoute: Hashable {
    case productDetails(Product)
    case postNewProduct
    case chat(chatRoom: ChatRoom, otherUser: User, productId: String)
}

class HomeNavigationCoordinator: ObservableObject {
    @Published var routes: [HomeRoute] = []
}
