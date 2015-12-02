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


class MasterViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, G8TesseractDelegate {
    
    var imagePicker: UIImagePickerController!
    @IBOutlet var imageView: UIImageView!
    var tesseractText = "none"
    var newMedia: Bool?
    
    @IBAction func tesseractUpdate(sender: UIButton){
        print("perform")
        self.performSegueWithIdentifier("Detail View Controller", sender:self)
        print("first")
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
        
        if let fetchResult: PHFetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions) {
            // If the fetch result isn't empty,
            // proceed with the image request

            // Perform the image request

            imgManager.requestImageForAsset(fetchResult.lastObject as! PHAsset, targetSize: view.frame.size, contentMode: PHImageContentMode.AspectFill, options: requestOptions, resultHandler: { (image, _) in
                let tesseract = G8Tesseract(language:"eng");
                tesseract.delegate = self;
                tesseract.engineMode = .TesseractCubeCombined
                tesseract.pageSegmentationMode = .Auto
                tesseract.maximumRecognitionTime = 60.0
                let newImage = self.scaleImage(image!, maxDimension:640);
                tesseract.image = image
                tesseract.recognize();
                print("before")
                print(tesseract.recognizedText)
                print("after")
                self.tesseractText = tesseract.recognizedText;
                
            })
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
            print("penis3")
            
            
        }
    }
    //    func shouldCancelImageRecognitionForTesseract(tesseract: Tesseract!) -> Bool {
    //        return false; // return true if you need to interrupt tesseract before it finishes
    //    }
    
    
}

