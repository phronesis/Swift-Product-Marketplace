import SwiftUI
import AmplifyImage
struct ProductGridCell: View {
    // 1
    let product: Product
    
    var body: some View {
        // 2
        ZStack(alignment: .bottomLeading) {
            // 3
            AmplifyImage(key: product.imageKey)
                .scaleToFillWidth()
            // 4
            Text("$\(product.price)")
                .bold()
                .foregroundColor(.white)
                .padding(4)
                .background(Color(white: 0.1, opacity: 0.6))
        }
    }
}
