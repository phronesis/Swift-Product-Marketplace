import Amplify
import Combine
import SwiftUI
struct HomeView: View {
    // 1
    @StateObject var navigationCoordinator: HomeNavigationCoordinator = .init()
    // 2
    @State var products: [Product] = []
    @State var tokens: Set<AnyCancellable> = []
    
    let columns = Array(repeating: GridItem(.flexible(minimum: 150)), count: 2)
    
    var body: some View {
        // 3
        NavigationStack(path: $navigationCoordinator.routes) {
            // 4
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(products) { product in
                        // 5
                        NavigationLink(value: HomeRoute.productDetails(product)) {
                            ProductGridCell(product: product)
                        }
                    }
                }
            }
            .navigationTitle("Home")
            // 6
            .toolbar {
                ToolbarItem {
                    Button(
                        action: { navigationCoordinator.routes.append(.postNewProduct) },
                        label: { Image(systemName: "plus") }
                    )
                }
            }
            // 7
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .postNewProduct:
                    PostProductView()
                case .productDetails(let product):
                    ProductDetailsView(product: product)
                        .environmentObject(navigationCoordinator)
                case .chat(chatRoom: let chatRoom, otherUser: let user, productId: let id):
                    MessagesView(chatRoom: chatRoom, otherUser: user, productId: id)
                }
            }
        }
        .onAppear(perform: observeProducts)
    }
    
    func observeProducts() {
        // 1
        Amplify.Publisher.create(
            Amplify.DataStore.observeQuery(for: Product.self)
        )
        .map(\.items)
        .receive(on: DispatchQueue.main)
        // 2
        .sink(
            receiveCompletion: { print($0) },
            receiveValue: { products in
                self.products = products.sorted {
                    guard
                        let date1 = $0.createdAt,
                        let date2 = $1.createdAt
                    else { return false }
                    return date1 > date2
                }
            }
        )
        .store(in: &tokens)
    }
}
