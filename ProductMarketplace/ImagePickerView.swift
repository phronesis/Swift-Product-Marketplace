import SwiftUI
struct ImagePickerView: UIViewControllerRepresentable {
    // 1
    @Binding var image: UIImage?
    // 2
    @Environment(\.dismiss) var dismiss
    
    // 3
    func makeCoordinator() -> ImagePickerCoordinator {
        ImagePickerCoordinator(self)
    }
    
    // 4
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = context.coordinator
        return imagePickerController
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

// 1
class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    let imagePickerView: ImagePickerView
    
    init(_ imagePickerView: ImagePickerView) {
        self.imagePickerView = imagePickerView
    }
    
    // 2
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePickerView.dismiss.callAsFunction()
    }
    
    // 3
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePickerView.dismiss.callAsFunction()
        
        guard let image = info[.originalImage] as? UIImage else { return }
        imagePickerView.image = image
    }
}
