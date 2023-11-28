import Amplify
import SwiftUI
struct PostProductView: View {
    @EnvironmentObject var userState: UserState
    @Environment(\.dismiss) var dismiss
    // 1
    @State var name: String = ""
    @State var price: String = ""
    @State var description: String = ""
    // 2
    @State var image: UIImage?
    @State var shouldShowImagePicker: Bool = false
    // 3
    @State var postButtonIsDisabled: Bool = false
    
    var body: some View {
        ScrollView {
            // 4
            VStack {
                Button(action: { shouldShowImagePicker = true }) {
                    SelectImageView()
                }
                TextField("Name", text: $name)
                TextField("Price", text: $price)
                    .keyboardType(.numberPad)
                TextField("Description", text: $description, axis: .vertical)
                    .lineLimit(1...3)
                
                Button("Post") {
                    Task { await postProduct() }
                }
                    .disabled(postButtonIsDisabled)
            }
        }
        .padding(.horizontal)
        .navigationTitle("New Product")
        .sheet(isPresented: $shouldShowImagePicker) {
            ImagePickerView(image: $image)
        }
    }
    
    // 5
    @ViewBuilder
    func SelectImageView() -> some View {
        if let image = self.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 250, height: 250)
                .clipped()
        } else {
            Image(systemName: "photo.on.rectangle.angled")
                .resizable()
                .scaledToFill()
                .frame(width: 250, height: 250)
        }
    }
    
    func postProduct() async {
        // 1
        guard
            let imageData = image.flatMap({ $0.jpegData(compressionQuality:1) }),
            let priceInt = Int(price)
        else { return }
        let productId = UUID().uuidString
        let productImageKey = productId + ".jpg"
        
        // 2
        postButtonIsDisabled = true
        
        do {
            // 3
            let key = try await Amplify.Storage.uploadData(
                key: productImageKey,
                data: imageData
            ).value
            
            // 4
            let newProduct = Product(
                id: productId,
                name: name,
                price: priceInt,
                imageKey: key,
                productDescription: description.isEmpty ? nil : description,
                userId: userState.userId
            )
            let savedProduct = try await Amplify.DataStore.save(newProduct)
            print("Saved product: \(savedProduct)")
            
            // 5
            dismiss.callAsFunction()
        } catch {
            print(error)
            postButtonIsDisabled = false
        }
    }
}
