//
//  ViewController.swift
//  IOSW1
//
//  Created by Mauricio Jacobo Romero on 24/09/2016.
//  Copyright © 2016 MJ. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

class ViewController: UIViewController {
    @IBOutlet weak var ISBNCode: SSNTextField!
    @IBOutlet weak var Results: UITextView!
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var bookAthors: UITextView!
    @IBOutlet weak var imageURL: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Results.isEditable = false
        ISBNCode.clearButtonMode = .always
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func clearButton(_ sender: AnyObject) {
        cleanMyView()
    }

    @IBAction func searchISBN(_ sender: AnyObject) {
        print("Search ------>>>>")
        print("\(ISBNCode.text!)")
        self.view.endEditing(true)
        executeISBNSearch()
    }
    
    func executeISBNSearch(){
        var authors:[String] = [String]()
        var tmpText:String = ""
        
        if (isConnectedToNetwork() == true) {
            
            Results.backgroundColor = UIColor.white
            Results.textColor = UIColor.black
            Results.text=""
            
            let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:" + "\(ISBNCode.text!)"
            let url   = NSURL(string: urls)
            let datos:NSData? = NSData(contentsOf: url! as URL)
            //cleanMyView()
            
            do{
                let key = "ISBN:" + "\(ISBNCode.text!)"
                let json = try JSONSerialization.jsonObject(with: datos! as Data, options: .mutableLeaves)
                let dico1 = json as! NSDictionary
            
                if ((dico1[key]) != nil) {
                    let dico2 = dico1[key] as! NSDictionary
                    
                    if(dico2["title"] != nil){
                        bookTitle.text = (dico2["title"] as! NSString) as String
                    }
                    
                    if (dico2["authors"] != nil) {
                        let dico3 = dico2["authors"] as! NSArray
                        for author in dico3 {
                            if let author = author as? NSDictionary,
                                let name = author["name"] as? String {
                                authors.append(name)
                            }
                        }
                        
                        for tmp in authors {
                            tmpText = tmpText + tmp + "\n"
                        }
                        
                        bookAthors.text = tmpText
                    }
                    
                    if (dico2["by_statement"] != nil){
                        tmpText = tmpText + "\nBy statement:\n" + ( dico2["by_statement"] as! String)
                        bookAthors.text = tmpText
                    }
                    
                    if (dico2["cover"] != nil) {
                        let dico4 = dico2["cover"] as! NSDictionary
                        var thumbnail = dico4.value(forKey: "medium") as? String
                        
                        if (thumbnail == nil) {
                            thumbnail = dico4.value(forKey: "small") as? String
                        }
                        
                        if let iurl = NSURL(string: thumbnail!) {
                            if let data = NSData(contentsOf: iurl as URL){
                                imageURL.image = UIImage (data: data as Data)
                            }
                        
                        }
                    }
                }
            } catch _ {
            
            }
        } else {
            Results.backgroundColor = UIColor.red
            Results.textColor = UIColor.white
            Results.text="Error: problemas con Internet."
        }
        
    }
    
    func cleanMyView () {
        Results.backgroundColor = UIColor.white
        Results.textColor = UIColor.black
        ISBNCode.text = ""
        bookTitle.text = ""
        bookAthors.text = ""
        Results.text = ""
        imageURL.image = nil
    }
    
    func isConnectedToNetwork()->Bool{
        
        var Status:Bool = false
        let url = NSURL(string: "https://openlibrary.org")
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "HEAD"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10.0
        
        var response: URLResponse?

        do {
            _ = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: &response) as NSData?
            } catch is Error{
              print("error")
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 200 {
                Status = true
            }
        }
        
        return Status
    }
}

