//
//  ShowItemCardTVC.swift
//  SellIt
//
//  Created by Sid Parmar on 2017-04-04.
//  Copyright © 2017 Sid Parmar. All rights reserved.
//

import UIKit

class ShowItemCardTVC: UITableViewController {
    var showItem: Item!

    //----------------------------------------------
    //--------- UI elemets defined here ---------
    @IBOutlet weak var image: UIImageView!

    @IBOutlet weak var itemTitle: UITextField!
    @IBOutlet weak var itemDescription: UITextField!

    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var location: UITextField!
    
    @IBAction func cancelBarButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let item = showItem{
            itemTitle.text = item.title
            itemDescription.text = "Description: \(item.description)"
            price.text = "CAD \(String(item.price))"
            location.text = "Location: \(item.location)"
            email.text = "Respond to - \(item.email)"
            
            //load the thumb image from the server
            let imgPath = item.image["thumb"]
            let url = URL(string: imgPath!)
            let data = try? Data(contentsOf: url!)
            image?.image = UIImage(data: data!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
