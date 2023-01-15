//
//  ViewController.swift
//  RecognitionApp
//
//  Created by Sergio Ordaz Romero on 15/01/23.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet var imageView: UIImageView!
    private var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            if let ciimage = CIImage(image: image) {
                detect(image: ciimage)
            }
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIButton) {
        present(imagePicker, animated: true)
    }
    
    private func detect(image: CIImage) {
        let modelConfig = MLModelConfiguration()
        if let coreModel = try? VNCoreMLModel(for: ImageRecognitionModelMaker(configuration: modelConfig).model) {
            let request = VNCoreMLRequest(model: coreModel) { request, error in
                guard let results = request.results as? [VNClassificationObservation] else {
                    fatalError("Error al cargar los resultados")
                }
                if let firstResult = results.first {
                    self.navigationItem.title = firstResult.identifier.capitalized
                }
                
            }
            
            let handler = VNImageRequestHandler(ciImage: image)
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }
}

