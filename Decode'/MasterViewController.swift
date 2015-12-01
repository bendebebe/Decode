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
    
    @IBAction func tesseractUpdate(sender: UIButton){
        translateText("hello")
    }
    @IBAction func imageButton(sender: UIButton) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //--- Take Photo from Camera ---//
    @IBAction func takePhotoFromCamera(sender: AnyObject)
    {
        self.presentCamera()
    }
    
    func presentCamera()
    {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        {
            print("Button capture")
            
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        else
        {
            // error msg
        }
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
        if(picker.sourceType == UIImagePickerControllerSourceType.Camera)
        {
            // Access the uncropped image from info dictionary
            let imageToSave: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            
            UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil);
            
            
            imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
            imagePicker.dismissViewControllerAnimated(true, completion: nil)
            self.savedImageAlert()
            
            let imgManager = PHImageManager.defaultManager()
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
            let requestOptions = PHImageRequestOptions()
            requestOptions.synchronous = true
            
            
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
            
            
            
        }
    }
    
    func translateText(text: String){
        
        let parameters1 = ["key":"AIzaSyAce0BL9xUWur47MTt2VwUB6qmKTzplX6Q","q":"\(translateText)"]
        var source: String!
        var translated: String! = "";
        self.tesseractLabel.text = "hi";
        var t = "";
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
        
        //        #print detect_response
        //        detect_response = json.loads(detect_response)
        //        source = "&source=" + detect_response["data"]["detections"][0][0]["language"]
        //        target = "&target=" + sys.argv[2]
        //
        //        final_url = base_url+key+text+source+target
        //        #print final_url
        //        translation = json.loads(urllib2.urlopen(final_url).read())
        //        #print translation
        //        #print detect_response
        //        print translation["data"]["translations"][0]["translatedText"]
        
        Alamofire.request(.GET, detect_url)
            .responseJSON { response in
                let json = JSON(response.data!)
                print(json.description);
                NSLog("@%", json.description);
                if json != nil {
                    source = json["data"]["detections"][0][0]["language"].string
                    self.tesseractLabel.text = detect_url
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

