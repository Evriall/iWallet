//
//  PlaceDetailsVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 5/9/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class PlaceDetailsVC: UIViewController {
    @IBOutlet weak var titleLbl: UILabel!
    var mapPlace: MapPlace?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let mapPlace = mapPlace {
            titleLbl.text = mapPlace.place
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismissDetail()
    }
}
