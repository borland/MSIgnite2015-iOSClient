//
//  MainTabBarController.swift
//  MSIgnite2015
//
//  Created by Orion Edwards on 2/09/15.
//  Copyright © 2015 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

class MainTabBarController : UITabBarController {
    override func viewDidLoad() {
        guard let storyboard = self.storyboard else {
            return
        }
        
        let tueVc = storyboard.instantiateViewControllerWithIdentifier("SessionListViewController") as! SessionListViewController
        let wedVc = storyboard.instantiateViewControllerWithIdentifier("SessionListViewController") as! SessionListViewController
        let thuVc = storyboard.instantiateViewControllerWithIdentifier("SessionListViewController") as! SessionListViewController
        let friVc = storyboard.instantiateViewControllerWithIdentifier("SessionListViewController") as! SessionListViewController
        
        tueVc.setLabel("Tuesday", imageName:"T", dayId:1);
        wedVc.setLabel("Wednesday", imageName:"W", dayId:2);
        thuVc.setLabel("Thurday", imageName:"T", dayId:3);
        friVc.setLabel("Friday", imageName:"F", dayId:4);
        
        setViewControllers([tueVc, wedVc, thuVc, friVc], animated: false)
    }
}
