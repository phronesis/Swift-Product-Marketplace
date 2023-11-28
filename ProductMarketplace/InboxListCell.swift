import AmplifyImage
import SwiftUI
struct InboxListCell: View {
    // 1
    let otherChatRoomMember: User
    let lastMessage: LastMessage
    
    // 2
    var otherUsersAvatarKey: String {
        otherChatRoomMember.id + ".jpg"
    }
    var productImageKey: String {
        lastMessage.productId + ".jpg"
    }
    var lastMessageDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(
            for: lastMessage.dateTime!.foundationDate,
            relativeTo: .now
        )
    }
    
    var body: some View {
        // 3
        HStack {
            AvatarView(state: .remote(avatarKey: otherUsersAvatarKey))
                .frame(width: 50, height: 50)
            VStack(alignment: .leading) {
                Text(lastMessage.body)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(otherChatRoomMember.username)
                    .font(.subheadline)
                
                Text(lastMessageDate)
            }
            Spacer()
            AmplifyImage(key: productImageKey)
                .scaleToFillWidth()
                .frame(width: 50)
        }
    }
}
