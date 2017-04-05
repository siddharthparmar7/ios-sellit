//
//  MyURLSessions.swift
//  SellIt
//
//  Created by Sid Parmar on 2017-03-30.
//  Copyright © 2017 Sid Parmar. All rights reserved.
//

import Foundation

class MyURLSessions {
    
    var contacts: [Item] = []
    //********************* Server path *********************
    let folderURL_to_request = "https://sell-it-siddharthparmar7.c9users.io/"
    let url_to_request = "https://sell-it-siddharthparmar7.c9users.io/items.json"
//    var image: UIImage?   

    //-----------------------------------------------------------------------
    //------------------- DownLoad data from Server -----------------
    
    func loadContactsWS(){
        
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
                    print("Data Returned \(jsonArray)")
//                    self.tableView.reloadData()
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
            
            for contactInfo in jsonArray{
                if let contact = contactInfo as? [String: Any]{
                    print(contact)
                    let newContact = Item()
                    newContact.title = contact["title"] as! String
                    //                    newContact.phoneNumber = contact["fees"] as! String
                    contacts.append(newContact)
                }
            }
        }catch{
            print("Error: \(jsonParseError?.debugDescription)")
        }
        return jsonArray
    }
    
    
    //-------------------------------------------------------------------------
    //----------------------------- Upload Data with JSON -----------------
    
    func saveContactsWS(_ contact: Item){
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
