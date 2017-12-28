//
//  ItemListViewController.swift
//  CookBook
//
//  Created by Deepika Kudaka on 19/12/17.
//  Copyright © 2017 Deepika Kudaka. All rights reserved.
//

import UIKit
import CoreData
/**
 Class to load List of Items of Selected Category.
 Incase of No network Connectivity it get data from ManagedObject of entity "ItemList"  or else it  get data from API which is displayed in table view.
 Network connectivity is checked  based on status code of URL response
 */
class ItemListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,parseDatadelegate {
    
    
    @IBOutlet weak var itemListTableView: UITableView!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    ///contains Category selected in CategoryList View
    var selectedCategory : String = ""
    /// contains item names of selected Category
    var itemList = [String]()
    /// contains urls ofimages of items of selected Category
    var imageURL = [String]()
    ///contains ids of items of selected Category
    var mealId = [String]()
    ///value is true when there is no network connectivity
    var networkIsOff : Bool = false
    ///Array for storing recent user item searches and loaded when there is no networkConnectivity.
    var cacheItemList:[NSManagedObject] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        let urlString = "http://www.themealdb.com/api/json/v1/1/filter.php?c=\(selectedCategory)"
        let parseJSONobj = ParseData()
        parseJSONobj.parseData(url: urlString)
        parseJSONobj.parseDatadel  = self
    }
    /**
     Function to get Data from Managed Object Array and reload it in item List Table View incase of No network Connectivity.
     */
    
    
    func getFromCoreData(){
        self.networkIsOff = true
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ItemList")
        do {
            self.cacheItemList = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        for each in self.cacheItemList {
            let categoryvalue = (each.value(forKeyPath: "category") as? String)!
            let mealname = (each.value(forKeyPath: "mealName") as? String)!
            
            if (!(self.itemList.contains(mealname)))&&(categoryvalue==self.selectedCategory){
                self.itemList.append(mealname)
                self.mealId.append((each.value(forKeyPath: "mealID") as? String)!)
            }
        }
        self.activityIndicatorView.stopAnimating()
        self.itemListTableView.reloadData()
    }
    
    /**
     Function to get Data from API and reload it in item List Table View incase of No network Connectivity.
     */
   func dataFromAPIToTableViewArray(fetchData:NSDictionary){
                self.networkIsOff = false
                let itemList = fetchData.value(forKey:"meals") as! NSArray
                for each in itemList {
                    let itemDict = each as! NSDictionary
                    self.itemList.append((itemDict.value(forKey: "strMeal")) as! String)
                    self.imageURL.append((itemDict.value(forKey: "strMealThumb")) as! String)
                    self.mealId.append((itemDict.value(forKey: "idMeal")) as! String)
                }
      
                self.activityIndicatorView.stopAnimating()
                self.itemListTableView.reloadData()
            
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return itemList.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        
        let cell = itemListTableView.dequeueReusableCell(withIdentifier: "itemListcell") as! ListTableViewCell
        cell.itemNameLabel.text = itemList[indexPath.row]
        
        if(!networkIsOff){
            let imgURL = NSURL(string:imageURL[indexPath.row])
            let data =  NSData(contentsOf : (imgURL as URL?)!)
            
            cell.imageView?.image = UIImage(data: data! as Data)
        }
        return cell
    }
    
    /**
     Function is called when user selects row in table view  and perform segue to Detail view controller and it stores user recent item searches in NSmanagedObject.
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "ItemList", in: managedContext)!
        let itemlist = NSManagedObject(entity: entity,  insertInto: managedContext)
        let mealid = mealId[(itemListTableView.indexPathForSelectedRow?.row)!]
        let mealname = itemList[(itemListTableView.indexPathForSelectedRow?.row)!]
        itemlist.setValue(mealid, forKeyPath: "mealID")
        itemlist.setValue(mealname, forKeyPath: "mealName")
        itemlist.setValue(selectedCategory, forKeyPath:"category")
        
        do {
            try managedContext.save()
            cacheItemList.append(itemlist)
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        performSegue(withIdentifier:"showScroll", sender: self)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DetailViewController{
            destination.selectedItem = mealId[(itemListTableView.indexPathForSelectedRow?.row)!]
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}

