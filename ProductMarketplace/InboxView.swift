import Amplify
import Combine
import SwiftUI
struct InboxView: View {
    @EnvironmentObject var userState: UserState
    // 1
    @State var chatRooms: [ChatRoom] = []
    // 2
    @State var users: [User] = []
    @State var tokens: Set<AnyCancellable> = []
    
    // 3
    var chatRoomAndMemberList: [(chatRoom: ChatRoom, user: User)] {
        let pairs = chatRooms.compactMap { chatRoom -> (ChatRoom, User)? in
            let otherUserId = chatRoom.otherMemberId(
                currentUser: userState.userId
            )
            guard let user = users.first(where: {$0.id == otherUserId}) else { return nil }
            return (chatRoom, user)
        }
        return pairs
    }
    
    var body: some View {
        NavigationStack {
            // 4
            List(chatRoomAndMemberList, id: \.0.id) { pair in
                // 5
                NavigationLink(value: ChatRoute.chatRoom(pair.chatRoom, pair.user)) {
                    if let lastMessage = pair.chatRoom.lastMessage {
                        // 6
                        InboxListCell(
                            otherChatRoomMember: pair.user,
                            lastMessage: lastMessage
                        )
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Inbox")
            .navigationDestination(for: ChatRoute.self) { route in
                switch route {
                case .chatRoom(let chatRoom, let user):
                    MessagesView(chatRoom: chatRoom, otherUser: user)
                }
            }
            .onAppear(perform: getChatRoomsAndUsers)
        }
    }
    
    func getChatRoomsAndUsers() {
        // 1
        Amplify.Publisher.create(
            Amplify.DataStore.observeQuery(
                for: ChatRoom.self,
                where: ChatRoom.keys.memberIds.contains(userState.userId)
            )
        )
        .map(\.items)
        // 2
        .flatMap({ chatRooms -> AnyPublisher<(chatRooms: [ChatRoom], users: [User]), Error> in
            let ids: [String] = chatRooms.map {
                $0.otherMemberId(currentUser: userState.userId)
            }
            
            let predicates: [QueryPredicate] = ids.map {
                User.keys.id == $0
            }
            
            let predicateGroup = QueryPredicateGroup(type: .or, predicates: predicates)
            
            return Amplify.Publisher.create {
                try await Amplify.DataStore.query(User.self, where: predicateGroup)
            }
            .map { (chatRooms, $0) }
            .eraseToAnyPublisher()
        })
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion:  { completion in
                if case .failure(let error) = completion {
                    print(error)
                }
            },
            // 3
            receiveValue: { results in
                self.chatRooms = results.chatRooms
                self.users = results.users
            }
        )
        .store(in: &tokens)
    }
}
