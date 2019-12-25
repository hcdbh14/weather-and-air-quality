//
//  CountryToStateSegue.swift
//  pollutionApp
//
//  Created by Kenny Kurochkin on 02/09/2019.
//  Copyright © 2019 kenny. All rights reserved.
//

import UIKit

class CountryToStateSegue: UIStoryboardSegue {
    
    
    func sendToState(for segue: UIStoryboardSegue, sender: Any?, tableview: UITableView, country: String) {
        if segue.identifier == "userChoseCountry" {
            if tableview.indexPathForSelectedRow != nil {
                let controller = segue.destination as! StatesTableViewController
                controller.chosenCountry = country
            }
        }
    }
}

