//
//  Settings.swift
//  DropTop
//
//  Created by Mnpn on 29/06/2018.
//  Copyright © 2018 Mnpn. All rights reserved.
//

import Foundation
class SettingsBundleHelper {
    struct SettingsBundleKeys {
        static let Reset = "RESET_APP"
        static let BuildVersionKey = "build_preference"
        static let AppVersionKey = "version_preference"
    }
    
    class func checkAndExecuteSettings() {
        if UserDefaults.standard.bool(forKey: SettingsBundleKeys.Reset) {
            // Reset the values.
            UserDefaults.standard.set(false, forKey: SettingsBundleKeys.Reset)
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            // Manually reset the auto-clear button as it defaults to "off".
            UserDefaults.standard.set(true, forKey: "aclb")
        }
    }
    
    class func setVersionAndBuildNumber() { // Set the version and build number in Settings.
        let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        UserDefaults.standard.set(version, forKey: "version")
        let build: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        UserDefaults.standard.set(build, forKey: "build")
    }
}
