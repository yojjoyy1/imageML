//
//  ViewController.swift
//  coreMLTest
//
//  Created by novastar on 2024/8/12.
//

import UIKit
import CoreML
import Vision
import MLImage
import MLKit
import MLKitTextRecognition
import MLKitTextRecognitionCommon
import MLKitTextRecognitionKorean
import MLKitTextRecognitionChinese
import MLKitTextRecognitionJapanese
import MLKitTextRecognitionDevanagari
import MarqueeLabel


class ViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {

    var imgV:UIImageView!
    var textView:UITextView!
    var photoBtn:UIButton!
    var cameraBtn:UIButton!
    var mlModel:MobileNetV2!
    let imagePredictor = ImagePredictor()
    var languageSeg:UISegmentedControl!
    var marqueeLabel:MarqueeLabel!
    var resultString:String!
    var resultArray = ["手機","phone","花","草","樹","flower","windy","風","看板","地板","floor","餐盒"," lunch box"]
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
        resultString = "手機"
    }
    func initCreateView(){
        self.view.backgroundColor = .white
        imgV = UIImageView(frame: .zero)
        imgV.contentMode = .scaleAspectFit
//        imgV.backgroundColor = .lightGray
        imgV.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(imgV)
        let imgVleading = NSLayoutConstraint(item: imgV, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 10)
        let imgVtop = NSLayoutConstraint(item: imgV, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: UIApplication.shared.statusBarFrame.height + 50);
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
        self.textView.addObserver(self, forKeyPath: "text", options: [.old,.new], context: nil)
        let textVleading = NSLayoutConstraint(item: textView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 10)
        let textVtop = NSLayoutConstraint(item: textView, attribute: .top, relatedBy: .equal, toItem: self.imgV, attribute: .bottom, multiplier: 1.0, constant: 10);
        let textVtrailing = NSLayoutConstraint(item: textView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: -10);
        let textVheight = NSLayoutConstraint(item: textView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: self.view.bounds.size.height * 0.2);
        NSLayoutConstraint.activate([textVleading,textVtop,textVtrailing,textVheight])
        photoBtn = UIButton(frame: .zero)
        photoBtn.translatesAutoresizingMaskIntoConstraints = false
        photoBtn.setTitle("開啟相簿", for: .normal)
        photoBtn.setTitleColor(.red, for: .normal)
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
        cameraBtn.setTitleColor(.red, for: .normal)
        cameraBtn.backgroundColor = .lightGray
        cameraBtn.addTarget(self, action: #selector(self.cameraAction), for: .touchUpInside)
        self.view.addSubview(cameraBtn)
        let cameraBtnleading = NSLayoutConstraint(item: cameraBtn, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 5)
        let cameraBtntrailing = NSLayoutConstraint(item: cameraBtn, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 10);
        let cameraBtnBottom = NSLayoutConstraint(item: cameraBtn, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -10);
        let cameraBtnHeight = NSLayoutConstraint(item: cameraBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: self.view.bounds.size.height * 0.1);
        NSLayoutConstraint.activate([cameraBtnleading,cameraBtntrailing,cameraBtnBottom,cameraBtnHeight])
        if languageSeg == nil{
            languageSeg = UISegmentedControl(items: ["中文","梵文","日文","韓文"])
            languageSeg.frame = .zero
            languageSeg.selectedSegmentIndex = 0
            languageSeg.selectedSegmentTintColor = .red
            languageSeg.tintColor = .white
            languageSeg.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(languageSeg)
            
            let segleading = NSLayoutConstraint(item: languageSeg, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 10)
            let segtrailing = NSLayoutConstraint(item: languageSeg, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: -10);
            let segTop = NSLayoutConstraint(item: languageSeg, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: UIApplication.shared.statusBarFrame.height + 5)
            let segBottom = NSLayoutConstraint(item: languageSeg, attribute: .bottom, relatedBy: .equal, toItem: self.imgV, attribute: .top, multiplier: 1.0, constant: -5);
            NSLayoutConstraint.activate([segleading,segtrailing,segTop,segBottom])
            
            if marqueeLabel == nil{
                self.view.layoutIfNeeded()
                marqueeLabel = MarqueeLabel(frame: CGRect(x: self.view.center.x - 50, y: self.cameraBtn.frame.origin.y - 50, width: 100, height: 40), duration: 3.0, fadeLength: 10)
                marqueeLabel.text = "請識別出含有\"\(self.resultString!)\"的字"
                marqueeLabel.textColor = .black
                marqueeLabel.animationCurve = .linear
//                marqueeLabel.type = .left
                self.view.addSubview(marqueeLabel)
            }
        }
        
    }
    func textML(image:UIImage){
        // When using Latin script recognition SDK
        let latinOptions = TextRecognizerOptions()
        let latinTextRecognizer = TextRecognizer.textRecognizer(options:latinOptions)

        // When using Chinese script recognition SDK
        let chineseOptions = ChineseTextRecognizerOptions()
        let chineseTextRecognizer = TextRecognizer.textRecognizer(options:chineseOptions)

        // When using Devanagari script recognition SDK
        let devanagariOptions = DevanagariTextRecognizerOptions()
        let devanagariTextRecognizer = TextRecognizer.textRecognizer(options:devanagariOptions)

        // When using Japanese script recognition SDK
        let japaneseOptions = JapaneseTextRecognizerOptions()
        let japaneseTextRecognizer = TextRecognizer.textRecognizer(options:japaneseOptions)

        // When using Korean script recognition SDK
        let koreanOptions = KoreanTextRecognizerOptions()
        let koreanTextRecognizer = TextRecognizer.textRecognizer(options:koreanOptions)
        
        let visionImage = VisionImage(image: image)
        var textRecognizer:TextRecognizer!
        switch self.languageSeg.selectedSegmentIndex{
        case 0:
            let chineseOptions = ChineseTextRecognizerOptions()
            textRecognizer = TextRecognizer.textRecognizer(options:chineseOptions)
            break
        case 1:
            let devanagariOptions = DevanagariTextRecognizerOptions()
            textRecognizer = TextRecognizer.textRecognizer(options:devanagariOptions)
            break
        case 2:
            let japaneseOptions = JapaneseTextRecognizerOptions()
            textRecognizer = TextRecognizer.textRecognizer(options:japaneseOptions)
            break
        case 3:
            let koreanOptions = DevanagariTextRecognizerOptions()
            textRecognizer = TextRecognizer.textRecognizer(options:koreanOptions)
            break
        default:
            let chineseOptions = ChineseTextRecognizerOptions()
            textRecognizer = TextRecognizer.textRecognizer(options:chineseOptions)
            break
        }
        textRecognizer.process(visionImage) {
            result, error in
            if error == nil{
                let resultText = result!.text
                self.textView.text += "\n圖片文字識別: "
//                print("讀取到的總訊息:\(resultText)")
                if let resultBlocks = result?.blocks{
                    self.parseORCText(resultBlocks: resultBlocks)
                }
            }
        }
    }
    func parseORCText(resultBlocks:[TextBlock]){
        for i in 0...resultBlocks.count - 1{
            let block = resultBlocks[i]
            let blockText = block.text
            let blockLanguages = block.recognizedLanguages
            let blockCornerPoints = block.cornerPoints
            let blockFrame = block.frame
            self.textView.text += "\n" + blockText
//            print("blockText:\(blockText)\nblockLanguages:\(blockLanguages)\nblockCornerPoints:\(blockCornerPoints)\nblockFrame:\(blockFrame)")
        }
    }
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
        print("imagePickerControllerDidCancel");
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("didFinishPickingMediaWithInfo:\(info)")
        self.textView.text = ""
        picker.dismiss(animated: true)
        let img = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as! UIImage
        self.imgV.image = img
        do {
            try self.imagePredictor.makePredictions(for: img,
                                                    completionHandler: imagePredictionHandler)
        } catch {
            print("Vision was unable to make a prediction...\n\n\(error.localizedDescription)")
        }
        /*firebase image ML
         let FBimage = VisionImage(image: img)
 //        visionImage.orientation = image.imageOrientation
         let options = ImageLabelerOptions()
         options.confidenceThreshold = 0.7
         let labeler = ImageLabeler.imageLabeler(options: options)
         labeler.process(FBimage) {
             labels, error in
             if error == nil{
                 for i in 0 ... labels!.count - 1{
                     let label = labels![i]
                     let labelText = label.text
                     let confidence = label.confidence
                     let index = label.index
                     print("index:\(index)\nlabel:\(label)\nlabelText:\(labelText)\nconfidence:\(confidence)")
                 }
             }
         }
         */
        self.textML(image: img)
    }

    
    private func imagePredictionHandler(_ predictions: [ImagePredictor.Prediction]?) {

        let formattedPredictions = formatPredictions(predictions!)

        let predictionString = formattedPredictions.joined(separator: "\n")
        
        self.textView.text += "圖片識別: " + predictionString
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
    //下燈籠特效
    func createlamps() {
        let lampLayer = CAEmitterLayer()
        lampLayer.emitterPosition = CGPoint(x: view.bounds.width / 2, y: 0)
        lampLayer.emitterSize = self.view.frame.size
        lampLayer.emitterShape = .line
        lampLayer.renderMode = .unordered
        lampLayer.emitterMode = .outline
        view.layer.addSublayer(lampLayer)

        let lamp = CAEmitterCell()
        lamp.contents = UIImage(named: "lamp")?.cgImage
        lamp.lifetime = 10
        lamp.lifetimeRange = 0.5
        lamp.birthRate = 5
        lamp.velocity = 100
        lamp.velocityRange = 50
        lamp.yAcceleration = 25.0
        lamp.xAcceleration = 3.0
        lamp.emissionLongitude = .pi
        lamp.emissionRange = .pi / 4
        lamp.scale = 0.5
        lamp.scaleRange = 0.2
        lampLayer.emitterCells = [lamp]

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.view.layer.replaceSublayer(lampLayer, with: CALayer())
        }
    }
    //MARK: 觀察者模式
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        print("observeValue forKeyPath:\(keyPath),object:\(object),change:\(change)")
        if object is UITextView {
            if let newName = change?[.newKey] as? String {
//                print("Name changed to: \(newName)")
                if newName.lowercased().contains(self.resultString!){
//                    self.resultString = "apple"
                    marqueeLabel.text = "請識別出含有\"\(self.resultString!)\"的字"
                    self.createlamps()
                    let random = Int(arc4random_uniform(UInt32(self.resultArray.count)))
//                    print("resultString:\(self.resultString),newResultString:\(self.resultArray[random])")
                    while self.resultArray[random] == self.resultString{
                        let random2 = Int(arc4random_uniform(UInt32(self.resultArray.count)))
                        self.resultString = self.resultArray[random2]
//                        print("aaaaa:\(self.resultArray[random2])")
//                        self.resultString = self.resultArray[random]
                    }
                    marqueeLabel.text = "請識別出含有\"\(self.resultString!)\"的字"
                }
            }
        }
    }
}

