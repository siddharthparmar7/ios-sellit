//
//  AllItemsTVC.swift
//  SellIt
//
//  Created by Sid Parmar on 2017-03-30.
//  Copyright © 2017 Sid Parmar. All rights reserved.
//

import UIKit

class AllItemsTVC: UITableViewController {
    
    //
    //************** all variables and constants **************
    var items: [Item] = []
    
    //********************* Server path *********************
    let folderURL_to_request = "https://sell-it-siddharthparmar7.c9users.io"
    let url_to_request = "https://sell-it-siddharthparmar7.c9users.io/items.json"
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadItemsWS()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row].title
        cell.detailTextLabel?.text = items[indexPath.row].description
        
        let imgPath = items[indexPath.row].image["thumb"]!
        cell.imageView?.image = image
        
        // Customize imageView like you need
        cell.imageView?.frame = CGRect(x: Int(cell.imageView!.frame.origin.x), y: Int(cell.imageView!.frame.origin.y), width: 50, height: 50);
        cell.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        
        let url = URL(string: imgPath)
        let data = try? Data(contentsOf: url!)
        cell.imageView?.image = UIImage(data: data!)
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sendItem = items[indexPath.row]
        performSegue(withIdentifier: "ShowItemCard", sender: sendItem)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //-----------------------------------------------------------------------
    //-----------------------------  segues  --------------------------------
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowItemCard" {
            let navController = segue.destination as! UINavigationController
            let controller = navController.topViewController as! ShowItemCardTVC
            controller.showItem = sender as! Item
        }
    }
    
    
    //-----------------------------------------------------------------------
    //------------------- DownLoad data from Server -----------------
    
    func loadItemsWS(){
        
        //make a request
        let url = URL(string: url_to_request)
        var request = URLRequest(url: url!)
        //set the http method
        request.httpMethod = "GET"
        //create a session
        let session = URLSession.shared
        //create and set up a task
        let task = session.dataTask(with: request, completionHandler: {
            data, response, error in
            DispatchQueue.main.async {
                guard let data = data, let _ = response, error == nil else {
                    print("Error: \(error.debugDescription) and Response: \(response)")
                    return
                }
                let jsonArray = self.parse(data: data)
                if jsonArray.count <= 0{
                    print("Can not conver to JSON or it's empty")
                }
                else{
                    self.tableView.reloadData()
                }
            }
        })
        //execute the task
        task.resume()
    }
    
    //-------------------------------------------------------------------------
    //------------------ Convert JSON response into NSArray -----------------
    
    func parse(data: Data) -> NSArray {
        let jsonParseError: NSErrorPointer = nil
        var jsonArray = NSArray()
        do{
            jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as! NSArray
            
            for itemsJson in jsonArray{
                if let item = itemsJson as? [String: Any]{
                    let newItem = Item()
                    newItem.title = item["title"] as! String
                    newItem.description = item["description"] as! String
                    newItem.price = item["price"] as! Double
                    newItem.email = item["email"] as! String
                    newItem.id = item["id"] as! Int
                    newItem.location = item["location"] as! String
                    newItem.category = item["category"] as! String
                    
                    // save the link for the thumb image
                    for image in item["image"] as! [String: Any] {
                        if image.value is [String: Any]{
                            let thumb = image.value as! [String: String]
                            newItem.image["thumb"] = folderURL_to_request + thumb["url"]!
                        }
                    }
                    items.append(newItem)
                }
            }
        }catch{
            print("Error: \(jsonParseError?.debugDescription)")
        }
        return jsonArray
    }
    
    
    //-------------------------------------------------------------------------
    //----------------------------- Upload Data with JSON -----------------
    
    func saveItemsWS(_ contact: Item){
        //make a request
        let url = URL(string: url_to_request)
        var request = URLRequest(url: url!)
        //set the http method
        request.httpMethod = "POST"
        //prepare data
        var jsonConact = [String: Any]()
        jsonConact["title"] = contact.title
        jsonConact["phone"] = contact.phone_number
        let data = try? JSONSerialization.data(withJSONObject: jsonConact, options: [])
        if data == nil{
            print("Error converting data into JSON")
            return
        }
        print("data after convertion: \(data)")
        //create a session
        let session = URLSession.shared
        //create and set up a task
        let task = session.uploadTask(with: request, from: data!,
                                      completionHandler: { data, response, error in
                                        guard let _ = data, let _ = response, error == nil else {
                                            print("Error while Uploading \(error) and respose: \(response)")
                                            return
                                        }
                                        print("Upload Succeded with response: \(response)")
        })
        //execute the task
        task.resume()
    }


}
