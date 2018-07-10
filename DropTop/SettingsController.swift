//
//  SettingsController.swift
//  DropTop
//
//  Created by Mnpn on 26/06/2018.
//  Copyright © 2018 Mnpn. All rights reserved.
//

import UIKit
import SpriteKit

class SettingsController: UIViewController {
    var intnl = Float(15.0)
    @IBOutlet weak var ACLB: UISwitch!
    @IBOutlet weak var getnl: UISlider!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func done(_ sender: Any) { // Done button pressed.
        // Save the settings to UserDefaults.
        UserDefaults.standard.set(getnl.value, forKey: "getnl")
        intnl = UserDefaults.standard.float(forKey: "getnl")
        UserDefaults.standard.set(ACLB.isOn, forKey: "aclb")
        // Dismiss the settings view to return to previous game instance.
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) { // Stuff to do before the settings view is visible
        if UserDefaults.standard.float(forKey: "getnl") == Float(0.0) { // Assume first launch
            // If the UserDefault is 0, the settings have never been saved.
            // Save the default settings to UserDefaults.
            UserDefaults.standard.set(intnl, forKey: "getnl")
        }
        // Set the UISlider value to the UserDefault.
        getnl.setValue(UserDefaults.standard.float(forKey: "getnl"), animated: false)
        // Set the UIButton value.
        ACLB.isOn = UserDefaults.standard.bool(forKey: "aclb")
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    //override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        // getnl.setValue(UserDefaults.standard.float(forKey: "getnl"), animated: false)
    //}
}
