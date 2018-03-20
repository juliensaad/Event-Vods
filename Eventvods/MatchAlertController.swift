//
//  MatchAlertController.swift
//  Eventvods
//
//  Created by Julien Saad on 2018-03-20.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit

class MatchAlertController: UIAlertController {

    var tintColor: UIColor = UIColor.black

    override func viewDidLoad() {
        super.viewDidLoad()

        view.tintColor = tintColor
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
