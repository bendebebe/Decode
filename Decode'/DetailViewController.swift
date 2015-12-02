//
//  DetailViewController.swift
//  Decode'
//
//  Created by bdebebe on 11/30/15.
//  Copyright © 2015 Decode. All rights reserved.
//

import UIKit
import Alamofire

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    @IBOutlet var tesseractLabel: UILabel!
    var translatedText : String!
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
                    print("micah")
                    source = json["data"]["detections"][0][0]["language"].string
                    
                    final_url = final_url+base_url+key+newText+"&source="+source+"&target="+target;
                    
                    
                    Alamofire.request(.GET, final_url)
                        .responseJSON { response in
                            //translation request
                            let json = JSON(data: response.data!)
                            if let final = json["data"]["translations"][0]["translatedText"].string {
                                //final translation
                                print(final)
                                self.translatedText = final
                                self.tesseractLabel.text = self.translatedText
                            }
                            else
                            {
                                self.tesseractLabel.text = "Could not translate."
                            }
                    }
                }
                else{
                    self.tesseractLabel.text = "Could not detect source language"
                }
                
        }
    }

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("penis4")
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        print("penis5")
        print(self.translatedText)
        translateText(self.translatedText, target: "es")
        print("penis6")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

