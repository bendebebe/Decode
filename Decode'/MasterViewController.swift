//
//  MasterViewController.swift
//  Decode'
//
//  Created by bdebebe on 11/30/15.
//  Copyright © 2015 Decode. All rights reserved.
//
import UIKit
import MobileCoreServices
import Photos
//import SwiftyJSON


class MasterViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, G8TesseractDelegate, UITextFieldDelegate, UIPickerViewDelegate {
    
    var imagePicker: UIImagePickerController!
    @IBOutlet var imageView: UIImageView!
    var tesseractText = "none"
    var sourceLangCodes = ["ara", "aze", "bul", "cat", "ces", "chi_sim", "chi_tra", "chr", "dan", "dan-frak", "deu", "ell", "eng", "enm", "epo", "est", "fin", "fra", "frm", "glg", "heb", "hin", "hrv", "hun", "ind", "ita", "jpn", "kor", "lav", "lit", "nld", "nor", "pol", "por", "ron", "rus", "slk", "slv", "sqi", "spa", "srp", "swe", "tam", "tel", "tgl", "tha", "tur", "ukr", "vie"]
    
    var sourceLangOptions = ["Arabic", "Azerbauijani", "Bulgarian", "Catalan", "Czech", "Simplified Chinese", "Traditional Chinese", "Cherokee", "Danish", "Danish (Fraktur)", "German", "Greek", "English", "Old English", "Esperanto", "Estonian", "Finnish", "French", "Old French", "Galician", "Hebrew", "Hindi", "Croation", "Hungarian", "Indonesian", "Italian", "Japanese", "Korean", "Latvian", "Lithuanian", "Dutch", "Norwegian", "Polish", "Portuguese", "Romanian", "Russian", "Slovakian", "Slovenian", "Albanian", "Spanish", "Serbian", "Swedish", "Tamil", "Telugu", "Tagalog", "Thai", "Turkish", "Ukrainian", "Vietnamese"]
    
    var targetLangCodes = ["af", "sq", "ar", "hy", "az", "eu", "be", "bn", "bs", "bg", "ca", "ceb", "ny", "zh", "zh-TW", "hr", "cs", "da", "nl", "en", "eo", "et", "tl", "fi", "fr", "gl", "ka", "de", "el", "gu", "ht", "ha", "iw", "hi", "hmn", "hu", "is", "ig", "id", "ga", "it", "ja", "jw", "kn", "kk", "km", "ko", "lo", "la", "lv", "lt", "mk", "mg", "ms", "ml", "mt", "mi", "mr", "mn", "my", "ne", "no", "fa", "pl", "pt", "pa", "ro", "ru", "sr", "st", "si", "sk", "sl", "so", "es", "su", "sw", "sv", "tg", "ta", "te", "th", "tr", "uk", "ur", "uz", "vi", "cy", "yi", "yo", "zu"]
    
    var targetLangOptions = ["Afrikaans", "Albanian", "Arabic", "Armenian", "Azerbaijani", "Basque", "Belarusian", "Bengali", "Bosnian", "Bulgarian", "Catalan", "Cebuano", "Chichewa", "Chinese (Simplified)", "Chinese (Traditional)", "Croatian", "Czech", "Danish", "Dutch", "English", "Esperanto", "Estonian", "Filipino", "Finnish", "French", "Galician", "Georgian", "German", "Greek", "Gujarati", "Haitian Creole", "Hausa", "Hebrew", "Hindi", "Hmong", "Hungarian", "Icelandic", "Igbo", "Indonesian", "Irish", "Italian", "Japanese", "Javanese", "Kannada", "Kazakh", "Khmer", "Korean", "Lao", "Latin", "Latvian", "Lithuanian", "Macedonian", "Malagasy", "Malay", "Malayalam", "Maltese", "Maori", "Marathi", "Mongolian", "Myanmar (Burmese)", "Nepali", "Norwegian", "Persian", "Polish", "Portuguese", "Punjabi", "Romanian", "Russian", "Serbian", "Sesotho", "Sinhala", "Slovak", "Slovenian", "Somali", "Spanish", "Sundanese", "Swahili", "Swedish", "Tajik", "Tamil", "Telugu", "Thai", "Turkish", "Ukrainian", "Urdu", "Uzbek", "Vietnamese", "Welsh", "Yiddish", "Yoruba", "Zulu"]
    
    var sourceLang: String = ""
    var targetLang: String = ""
    @IBOutlet weak var sourceTextField: UITextField!
    @IBOutlet weak var targetTextField: UITextField!
    let sourcePickerView = UIPickerView()
    let targetPickerView = UIPickerView()
    @IBAction func tesseractUpdate(sender: UIButton){
        print("perform")
        self.performSegueWithIdentifier("Detail View Controller", sender:self)
        print("first")
    }
    
    @IBAction func sourceButton(sender: UIButton) {
        ActionSheetStringPicker.showPickerWithTitle("Pick Source Language", rows: sourceLangOptions, initialSelection: 0, doneBlock: {
            picker, value, index in
            
            self.sourceLang = self.sourceLangCodes[index as! Int]
            return
            }, cancelBlock: { ActionStringCancelBlock in return }, origin: sender)
        }

    @IBAction func targetButton(sender: UIButton){
        ActionSheetStringPicker.showPickerWithTitle("Pick Target Language", rows: targetLangOptions, initialSelection: 0, doneBlock: {
            picker, value, index in
            
            self.targetLang = self.targetLangCodes[index as! Int]
            return
            }, cancelBlock: { ActionStringCancelBlock in return }, origin: sender)
        }
    //--- Take Photo from Camera ---//
    @IBAction func imageButton(sender: UIButton) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        imagePicker.allowsEditing = false
        
        print("popp")
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func useCameraRoll(sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.allowsEditing = false
        
        self.presentViewController(imagePicker, animated: true,
            completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        
        self.sourcePickerView.delegate = self
        self.targetPickerView.delegate = self
        
        sourceTextField.inputView = self.sourcePickerView
        targetTextField.inputView = self.targetPickerView
        
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.sourcePickerView {
            return self.sourceLangOptions.count
        }
        else {
            return self.targetLangOptions.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.sourcePickerView {
            return self.sourceLangOptions[row]
        }
        else {
            return self.targetLangOptions[row]
        }
    }
    
    func sourcePickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        sourceTextField.text = self.sourceLangOptions[row]
        self.sourceLang = self.sourceLangCodes[row]
        self.sourceTextField.resignFirstResponder()
    }
    func targetPickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        targetTextField.text = self.sourceLangOptions[row]
        self.targetLang = self.sourceLangCodes[row]
        self.targetTextField.resignFirstResponder()
        self.targetTextField.resignFirstResponder()
    }
    
    //Mark- UIImagePickerController Delegate
    
    func imagePickerControllerDidCancel(picker:UIImagePickerController)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print(0)
        var image : UIImage!
        if(picker.sourceType == UIImagePickerControllerSourceType.Camera)
        {
            print(1)
            // Access the uncropped image from info dictionary
            let imageToSave: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            print(2)
            UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil);
            print(3)
            image = imageToSave
            imageView.image = imageToSave
            print(4)
            imagePickerControllerDidCancel(picker)

        }
        else if (picker.sourceType == UIImagePickerControllerSourceType.PhotoLibrary) {
            let mediaType = info[UIImagePickerControllerMediaType] as! NSString
            
            if mediaType.isEqualToString(kUTTypeImage as String) {
                
                // Media is an image  
                let imageToDisplay : UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
                imageView.contentMode = .ScaleAspectFit
                image = imageToDisplay
                imageView.image = imageToDisplay
                imagePickerControllerDidCancel(picker)
                
            }
        }
        
        if image != nil {
            let tesseract = G8Tesseract(language:self.sourceLang);
            tesseract.delegate = self;
            tesseract.engineMode = .TesseractCubeCombined
            tesseract.pageSegmentationMode = .Auto
            tesseract.maximumRecognitionTime = 60.0
            let newImage = self.scaleImage(image!, maxDimension:640);
            tesseract.image = newImage
            tesseract.recognize();
            print("before")
            print(tesseract.recognizedText)
            print("after")
            self.tesseractText = tesseract.recognizedText;

        }
    }
    
    
    
    func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        var scaleFactor: CGFloat
        
        if image.size.width > image.size.height {
            scaleFactor = image.size.height / image.size.width
            scaledSize.width = maxDimension
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            scaleFactor = image.size.width / image.size.height
            scaledSize.height = maxDimension
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        image.drawInRect(CGRectMake(0, 0, scaledSize.width, scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
        

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "Detail View Controller") {
            print("penis1")
            let secondViewController = segue.destinationViewController as! DetailViewController
            print("penis2")
            print(self.tesseractText)
            secondViewController.translatedText = self.tesseractText
            secondViewController.targetLang = self.targetLang
            print("penis3")
        }
    }
}

