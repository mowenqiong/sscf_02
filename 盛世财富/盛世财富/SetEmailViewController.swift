//
//  SetEmailViewController.swift
//  盛世财富
//
//  Created by hhh on 15-4-20.
//  Copyright (c) 2015年 sscf88. All rights reserved.
//

import Foundation
import UIKit

class SetEmailViewController:UIViewController,UITextFieldDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func returnTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}