//
//  SlideVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/22/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class SlideVC: UIViewController {


    @IBAction func openMainBtnPressed(_ sender: Any) {
        let mainVC = storyboard?.instantiateViewController(withIdentifier: "MainVC")
        revealViewController().pushFrontViewController(mainVC, animated: true)
    }
    
    @IBAction func openReportBtnPressed(_ sender: Any) {
        let reportVC = storyboard?.instantiateViewController(withIdentifier: "ReportVC")
        revealViewController().pushFrontViewController(reportVC, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.revealViewController().rearViewRevealWidth = self.view.frame.size.width - 60
    }

}
