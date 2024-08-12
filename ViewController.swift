//
//  ViewController.swift
//  coreMLTest
//
//  Created by novastar on 2024/8/12.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {

    var imgV:UIImageView!
    var textView:UITextView!
    var photoBtn:UIButton!
    var cameraBtn:UIButton!
    var mlModel:MobileNetV2!
    let imagePredictor = ImagePredictor()
    //最大預測數
    let predictionsToShow = 2
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        initCreateView()
    }

    //MARK: 自訂方法
    @objc func cameraAction(){
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        cameraPicker.allowsEditing = false
        present(cameraPicker, animated: true)
    }
    @objc func openLibraryAction(){
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    func initData(){
        let defaultConfig = MLModelConfiguration()
        mlModel = try? MobileNetV2(configuration: defaultConfig)
    }
    func initCreateView(){
        self.view.backgroundColor = .white
        imgV = UIImageView(frame: .zero)
        imgV.contentMode = .scaleAspectFit
        imgV.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(imgV)
        let imgVleading = NSLayoutConstraint(item: imgV, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 10)
        let imgVtop = NSLayoutConstraint(item: imgV, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 10);
        let imgVtrailing = NSLayoutConstraint(item: imgV, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: -10);
        let imgVheight = NSLayoutConstraint(item: imgV, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: self.view.bounds.size.height * 0.5);
        NSLayoutConstraint.activate([imgVleading,imgVtop,imgVtrailing,imgVheight])
        textView = UITextView(frame: .zero)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = .black
        textView.backgroundColor = .white
        textView.isSelectable = false
        textView.isEditable = false
        self.view.addSubview(textView)
        let textVleading = NSLayoutConstraint(item: textView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 10)
        let textVtop = NSLayoutConstraint(item: textView, attribute: .top, relatedBy: .equal, toItem: self.imgV, attribute: .bottom, multiplier: 1.0, constant: 10);
        let textVtrailing = NSLayoutConstraint(item: textView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: -10);
        let textVheight = NSLayoutConstraint(item: textView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: self.view.bounds.size.height * 0.2);
        NSLayoutConstraint.activate([textVleading,textVtop,textVtrailing,textVheight])
        photoBtn = UIButton(frame: .zero)
        photoBtn.translatesAutoresizingMaskIntoConstraints = false
        photoBtn.setTitle("開啟相簿", for: .normal)
        photoBtn.setTitleColor(.black, for: .normal)
        photoBtn.backgroundColor = .lightGray
        photoBtn.addTarget(self, action: #selector(self.openLibraryAction), for: .touchUpInside)
        self.view.addSubview(photoBtn)
        let photoBtnleading = NSLayoutConstraint(item: photoBtn, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 10)
        let photoBtntrailing = NSLayoutConstraint(item: photoBtn, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: -5);
        let photoBtnBottom = NSLayoutConstraint(item: photoBtn, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -10);
        let photoBtnHeight = NSLayoutConstraint(item: photoBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: self.view.bounds.size.height * 0.1);
        NSLayoutConstraint.activate([photoBtnleading,photoBtntrailing,photoBtnBottom,photoBtnHeight])
        cameraBtn = UIButton(frame: .zero)
        cameraBtn.translatesAutoresizingMaskIntoConstraints = false
        cameraBtn.setTitle("開啟相機", for: .normal)
        cameraBtn.setTitleColor(.systemGreen, for: .normal)
        cameraBtn.backgroundColor = .darkGray
        cameraBtn.addTarget(self, action: #selector(self.cameraAction), for: .touchUpInside)
        self.view.addSubview(cameraBtn)
        let cameraBtnleading = NSLayoutConstraint(item: cameraBtn, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 5)
        let cameraBtntrailing = NSLayoutConstraint(item: cameraBtn, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 10);
        let cameraBtnBottom = NSLayoutConstraint(item: cameraBtn, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -10);
        let cameraBtnHeight = NSLayoutConstraint(item: cameraBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: self.view.bounds.size.height * 0.1);
        NSLayoutConstraint.activate([cameraBtnleading,cameraBtntrailing,cameraBtnBottom,cameraBtnHeight])
    }
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
        print("imagePickerControllerDidCancel");
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("didFinishPickingMediaWithInfo:\(info)")
        picker.dismiss(animated: true)
        let img = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as! UIImage
        /*
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 224, height: 224), true, 1.0)
        img.draw(in: CGRect(x: 0, y: 0, width: 224, height: 224))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        CVPixelBufferCreate(kCFAllocatorDefault, Int(newImage.size.width), Int(newImage.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(newImage.size.width), height: Int(newImage.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        UIGraphicsPushContext(context!)
        newImage.draw(in: CGRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        self.imgV.image = newImage
        if let prediction = try? mlModel.prediction(image: pixelBuffer!){
            print("\(prediction.classLabelProbs)")
            self.textView.text = prediction.classLabel
        }else{
            self.textView.text = "無法識別"
        }
        */
        self.imgV.image = img
        do {
            try self.imagePredictor.makePredictions(for: img,
                                                    completionHandler: imagePredictionHandler)
        } catch {
            print("Vision was unable to make a prediction...\n\n\(error.localizedDescription)")
        }
    }

    
    private func imagePredictionHandler(_ predictions: [ImagePredictor.Prediction]?) {

        let formattedPredictions = formatPredictions(predictions!)

        let predictionString = formattedPredictions.joined(separator: "\n")
        
        self.textView.text = predictionString
    }
    
    private func formatPredictions(_ predictions: [ImagePredictor.Prediction]) -> [String] {
        // Vision sorts the classifications in descending confidence order.
        let topPredictions: [String] = predictions.prefix(predictionsToShow).map { prediction in
            var name = prediction.classification

            // For classifications with more than one name, keep the one before the first comma.
            if let firstComma = name.firstIndex(of: ",") {
                name = String(name.prefix(upTo: firstComma))
            }

            return "\(name) - \(prediction.confidencePercentage)%"
        }

        return topPredictions
    }
}

