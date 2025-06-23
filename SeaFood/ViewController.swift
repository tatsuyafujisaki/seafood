import CoreML
import UIKit
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var imageView: UIImageView!

    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert UIImage into CIImage")
            }
            detect(image: ciimage)
        }

        imagePicker.dismiss(animated: true)
    }

    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3(configuration: .init()).model) else {
            fatalError("Loading CoreML Model Failed.")
        }
        let request = VNCoreMLRequest(model: model, completionHandler: { request, _ in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image.")
            }
            print(results)
        })
        let handler = VNImageRequestHandler(ciImage: image)

        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true)
    }
}
