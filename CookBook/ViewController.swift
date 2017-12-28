//
//  ViewController.swift
//  CookBook
//
//  Created by Deepika Kudaka on 19/12/17.
//  Copyright © 2017 Deepika Kudaka. All rights reserved.
//

import UIKit
import CoreData

/**
 ViewController for managing categoriesListView in app.
 
it contains methods and properties for loading the view and moving to ItemlistviewController when a cateogry is selected.
 */
class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,parseDatadelegate{
   
    
    ///Array for storing list of categories fetched from API.
    var categoryArray  = [String]()
    ///Array for storing recent user searches of categories loaded when there is no networkConnectivity.
    var cacheCategory : [NSManagedObject] = []
    ///URL String to fetch data from API
    let urlString = "http://www.themealdb.com/api/json/v1/1/list.php?c=list"
    //Property is true when Device not connected to Network
    var isNetworkOff : Bool = false
    @IBOutlet weak var categoryTableView: UITableView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTable(notification:)), name: Notification.Name(rawValue :"NotificationIdentifier"), object:nil)
    
    }
    override func viewWillAppear(_ animated: Bool) {
        let parsejsonObj = ParseData()
        parsejsonObj.parseDatadel = self
        parsejsonObj.parseData(url: urlString)
        
        
    }
   
/**
    or else it  get data from API and place it in category Array which is displayed in table view.
     
 */
    func dataFromAPIToTableViewArray(fetchData: NSDictionary) {
        isNetworkOff = false
        let category = fetchData.value(forKey:"meals") as! NSArray
        self.categoryArray.removeAll()
        for each in category {
            let categoryDict = each as! NSDictionary
            self.categoryArray.append((categoryDict.value(forKey: "strCategory")) as! String)
        }
       
            self.categoryTableView.reloadData()
    }
    
/** Function to get Data and reload it in Table View incase of No network Connectivity it get data from ManagedObject Model with entity "Category"  with attribute "category"*/
    func getFromCoreData(){
        isNetworkOff = true
        self.categoryArray.removeAll()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CategoryName")
        do {
            self.cacheCategory = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        for each in self.cacheCategory {
            let categoryvalue = (each.value(forKeyPath: "category") as? String)!
            if !(self.categoryArray.contains(categoryvalue)){
                self.categoryArray.append(categoryvalue)
            }
        }
        self.categoryTableView.reloadData()
    }
  ///Funtion called when App enters Foreground(applicationWillEnterForeground posts Notification)
    @objc func updateTable(notification : NSNotification){
        let parsejsonObj = ParseData()
        parsejsonObj.parseDatadel = self
        parsejsonObj.parseData(url: urlString)
        
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
      
        return categoryArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
      let cell = categoryTableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = categoryArray[indexPath.row]
        
        return cell!
    }
    /**
    Function is called when user selects row in table view and it stores user recent 5 searches in NSmanagedObject.
  */
    
    func cacheData(tableRowIndex : Int){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "CategoryName", in: managedContext)!
        let category = NSManagedObject(entity: entity,  insertInto: managedContext)
        let categoryValue = categoryArray[tableRowIndex]
        category.setValue(categoryValue, forKeyPath: "category")
        
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CategoryName")
            do {
                self.cacheCategory = try managedContext.fetch(fetchRequest)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            if  self.cacheCategory.count > 5 {
                self.cacheCategory.remove(at:0)
            }
        do{
          try managedContext.save()
            cacheCategory.append(category) }
        catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if !isNetworkOff {
            cacheData(tableRowIndex : (categoryTableView.indexPathForSelectedRow?.row)!)
        }
        
        performSegue(withIdentifier:"ShowDetails", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ItemListViewController{
            destination.selectedCategory = categoryArray[(categoryTableView.indexPathForSelectedRow?.row)!]
            
        }
        
    }
    
}

