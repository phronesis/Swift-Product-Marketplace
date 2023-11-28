import Amplify
import AmplifyImage
import SwiftUI
struct ProductDetailsView: View {
    @EnvironmentObject var userState: UserState
    @EnvironmentObject var navigationCoordinator: HomeNavigationCoordinator
    @Environment(\.dismiss) var dismiss
    // 1
    let product: Product
    
    var body: some View {
        ScrollView {
            // 2
            VStack {
                AmplifyImage(key: product.imageKey)
                    .scaleToFillWidth()
                
                Text("$\(product.price)")
                    .font(.largeTitle)
                
                product.productDescription.flatMap(Text.init)
                
                // 3
                if userState.userId != product.userId {
                    Button("Chat", action: {})
                } else {
                    Button("Delete product") {
                        Task { await deleteProduct() }
                    }
                }
            }
            .navigationTitle(product.name)
        }
    }
    
    func deleteProduct() async {
        do {
            // 1
            try await Amplify.DataStore.delete(product)
            print("Deleted product \(product.id)")
            
            // 2
            let productImageKey = product.id + ".jpg"
            try await Amplify.Storage.remove(key: productImageKey)
            print("Deleted file: \(productImageKey)")
            
            dismiss.callAsFunction()
        } catch {
            print(error)
        }
    }
    
    func getOrCreateChatRoom() async {
        do {
            // 1
            let chatRooms = try await Amplify.DataStore.query(
                ChatRoom.self,
                where: ChatRoom.keys.memberIds.contains(product.userId)
                    && ChatRoom.keys.memberIds.contains(userState.userId)
            )
            
            // 2
            let chatRoom: ChatRoom
            if let existingChatRoom = chatRooms.first {
                chatRoom = existingChatRoom
            } else {
                let newChatRoom = ChatRoom(memberIds: [product.userId, userState.userId])
                let savedChatRoom = try await Amplify.DataStore.save(newChatRoom)
                chatRoom = savedChatRoom
            }
            
            // 3
            let otherUser = (try await Amplify.DataStore.query(
                User.self,
                byId: chatRoom.otherMemberId(currentUser: userState.userId)
            ))!
            
            // 4
            navigationCoordinator.routes.append(.chat(chatRoom: chatRoom, otherUser: otherUser, productId: product.id))
        } catch {
            print(error)
        }
    }
}
