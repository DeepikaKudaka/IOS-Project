//
//  DetailViewController.swift
//  CookBook
//
//  Created by Deepika Kudaka on 19/12/17.
//  Copyright © 2017 Deepika Kudaka. All rights reserved.
//

import UIKit
/**
 Class loads and manages item Detail view Controller.
 it contains methods and properties to get data from NSURLCache or from API based on network Connectivity.
 */
class DetailViewController: UIViewController {

    
    @IBOutlet weak var receipesidelabel: UILabel!
    
    @IBOutlet weak var itemNameLabel: UILabel!
    
    @IBOutlet weak var itemImage: UIImageView!
    
 
    @IBOutlet weak var receipeLabel: UILabel!
    
    @IBOutlet weak var acitivtyIndicator: UIActivityIndicatorView!
    
    ///contains API Request URL
    var request : NSURLRequest?
    //contains response from URL and stored in Array
    var cacheResponse : CachedURLResponse?
    //Holds item selected in Item List View
    var selectedItem : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = "http://www.themealdb.com/api/json/v1/1/lookup.php?i=\(selectedItem)"
        parseData(url: url)
        
    }
    /**
     Function to parse Detais of item data From API in case of connected to network or else loaded from URL Cache  and load it in Details item View .
     Takes URL of API as input .
    */
    func parseData(url:String){
        
        self.request = NSURLRequest(url:URL(string : url)!, cachePolicy: NSURLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 60)
        let cacheResponse = URLCache.shared.cachedResponse(for: self.request! as URLRequest)

        var request = URLRequest(url: URL(string:url)!)
        request.httpMethod = "GET"
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
            let res = response as! HTTPURLResponse!
            if(res?.statusCode != 200){
                do{
                    let cacheDict =  try JSONSerialization.jsonObject(with: (cacheResponse?.data)!, options: .mutableLeaves) as? NSDictionary
                    let cacheArray = cacheDict!.value(forKey: "meals") as! NSArray
                    for each in cacheArray {
                        let categoryDict = each as! NSDictionary
                         self.itemNameLabel.text  = ((categoryDict.value(forKey: "strMeal")) as! String)
                         self.receipesidelabel.text = "RECEIPE"
                         self.receipeLabel.text = ((categoryDict.value(forKey: "strInstructions")) as! String)
                    
                    }
                   self.acitivtyIndicator.stopAnimating()
                    
                }catch{
                    print("error 1")
                }

            }
            else{
                do{
                    let fetchedData = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as? NSDictionary
                    let item = fetchedData!.value(forKey:"meals") as! NSArray
                    for each in item {
                        let itemDict = each as! NSDictionary
                        self.itemNameLabel.text = (itemDict.value(forKey: "strMeal")) as? String
                        let imageurl = (itemDict.value(forKey: "strMealThumb")) as! String
                        let imgURL = NSURL(string:imageurl)
                        let data =  NSData(contentsOf : (imgURL as URL?)!)
                        
                        self.itemImage.image = UIImage(data: data! as Data)
                        self.receipeLabel.text = (itemDict.value(forKey: "strInstructions")) as? String
                        
                        self.receipesidelabel.text = "RECEIPE"
                        
                    }
                    self.acitivtyIndicator.stopAnimating()
                }
                catch{
                    print("error 2")
                }
            }
        }
        
        task.resume()
    }
   

}
