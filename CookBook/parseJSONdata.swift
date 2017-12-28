//
//  parseJSONdata.swift
//  CookBook
//
//  Created by Deepika Kudaka on 22/12/17.
//  Copyright © 2017 Deepika Kudaka. All rights reserved.
//

import Foundation
///Protocol conatins methods which are called based on network Connectivity.
protocol parseDatadelegate {
    func getFromCoreData()
    func dataFromAPIToTableViewArray(fetchData:NSDictionary)
}
/**
  Class Cotains Properties and Methods to Parse Data from Api and Call Methods of Respective ViewController based on Network Connectivity of App.
 */
class ParseData:NSObject{
    
    //Holds Delegate of ViewController Object
    var parseDatadel : parseDatadelegate?
    /**
     Method to parse API data and call Methods based on Network Connectivity of App.
     Takes URL as input.Network connectivity is checked  based on status code of URL response.
   */
    func parseData(url : String){
        var request = URLRequest(url: URL(string:url)!)
        request.httpMethod = "GET"
        var fetchedData : NSDictionary?
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate:nil, delegateQueue:nil)
        let task = session.dataTask(with: request) { (data, response, error) in
            let res = response as! HTTPURLResponse!
             DispatchQueue.main.async {
            if(res?.statusCode != 200){
                self.parseDatadel?.getFromCoreData()
            }
            else {
                do{
                    fetchedData = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as? NSDictionary
                    self.parseDatadel?.dataFromAPIToTableViewArray(fetchData:fetchedData!)
                } catch{
                    print("Not JSON Data")
                }
            }
        }
    }
        task.resume()
     }
}
