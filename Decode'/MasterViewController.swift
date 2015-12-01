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
import SwiftyJSON
import Alamofire

class MasterViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var imagePicker: UIImagePickerController!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var tesseractLabel: UILabel!
    var tesseractText: String!
    var newMedia: Bool?
    
    @IBAction func tesseractUpdate(sender: UIButton){
        translateText("hello", target: "es")
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
    }
    
    
    func savedImageAlert()
    {
        let alertController:UIAlertController = UIAlertController(title: "Image Saved", message: "Your message has been saved", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            // ...
        }
        alertController.addAction(OKAction)
    }
    
    //Mark- UIImagePickerController Delegate
    
    func imagePickerControllerDidCancel(picker:UIImagePickerController)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print(0)
        if(picker.sourceType == UIImagePickerControllerSourceType.Camera)
        {
            print(1)
            // Access the uncropped image from info dictionary
            let imageToSave: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            print(2)
            UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil);
            print(3)
            imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
            print(4)
            imagePickerControllerDidCancel(picker)
            print(5)
            self.savedImageAlert()
            newMedia = true
        }
        else if (picker.sourceType == UIImagePickerControllerSourceType.PhotoLibrary) {
            let mediaType = info[UIImagePickerControllerMediaType] as! NSString
            
            if mediaType.isEqualToString(kUTTypeImage as String) {
                
                // Media is an image  
                let imagetoDisplay : UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
                imageView.contentMode = .ScaleAspectFit
                imageView.image = imagetoDisplay
                imagePickerControllerDidCancel(picker)
                
            }
        }
        let imgManager = PHImageManager.defaultManager()
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
        let requestOptions = PHImageRequestOptions()
        requestOptions.synchronous = true
        }
    
        
        //            UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil);
        //            imagePicker.dismissViewControllerAnimated(true, completion: nil)
        //            // Access the uncropped image from info dictionary
        //            print(2)
        //            let imageToSave: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        //
        //
        //
        //            print(3)
        //
        //            imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        //            print(4)
        //            UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil);
        //            print(5)
        //            self.savedImageAlert()
        //
        
        //            if let fetchResult: PHFetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions) {
        //                // If the fetch result isn't empty,
        //                // proceed with the image request
        //
        //                // Perform the image request
        //
        //                imgManager.requestImageForAsset(fetchResult.lastObject as! PHAsset, targetSize: view.frame.size, contentMode: PHImageContentMode.AspectFill, options: requestOptions, resultHandler: { (image, _) in
        //                    let tesseract:Tesseract = Tesseract(language:"eng");
        //                    tesseract.delegate = self;
        //                    tesseract.setVariableValue("01234567890", forKey: "tessedit_char_whitelist");
        //                    tesseract.image = image;
        //                    tesseract.recognize();
        //                    self.tesseractText = tesseract.recognizedText;
        //                })
        //            }
        
    
    
    func translateText(text: String, target: String){
        var source: String!
        var t = "&q=";
        for i in text.characters {
            let s = String(i).unicodeScalars
            let ord = s[s.startIndex].value
            if (ord < 128){
                t = t+String(i)
            }
        }
        let replaced = t.stringByReplacingOccurrencesOfString("\n", withString: "+")
        let split_text = replaced.componentsSeparatedByString(" ")
        
        
        var detect_text = ""
        for i in split_text {
            detect_text = detect_text + i+"+"
        }
        let range = Range(start: (detect_text.startIndex), end: ((detect_text.endIndex.advancedBy(-1))));
        detect_text = detect_text.substringWithRange(range)
        let newText = detect_text.stringByReplacingOccurrencesOfString("+", withString: "%20")
        let base_url = "https://www.googleapis.com/language/translate/v2"
        let key = "?key=AIzaSyAce0BL9xUWur47MTt2VwUB6qmKTzplX6Q"
        let detect_url = base_url + "/detect" + key + detect_text
        var final_url = ""
        
        
        Alamofire.request(.GET, detect_url)
            .responseJSON { response in
                //language detection
                let json = JSON(data: response.data!)
                if json["data"]["detections"][0][0]["language"].string != nil {
                    source = json["data"]["detections"][0][0]["language"].string

                    final_url = final_url+base_url+key+newText+"&source="+source+"&target="+target;

                    
                    Alamofire.request(.GET, final_url)
                        .responseJSON { response in
                            //translation request
                            let json = JSON(data: response.data!)
                            if json["data"]["translations"][0]["translatedText"].string != nil {
                                //final translation
                                self.tesseractLabel.text = json["data"]["translations"][0]["translatedText"].string
                            }
                    }
                }
        }
        
        
        
}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        
        
    }
    //    func shouldCancelImageRecognitionForTesseract(tesseract: Tesseract!) -> Bool {
    //        return false; // return true if you need to interrupt tesseract before it finishes
    //    }
    
    
}

