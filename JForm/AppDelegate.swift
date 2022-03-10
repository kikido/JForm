//
//  AppDelegate.swift
//  JForm
//
//  Created by dqh on 2021/7/19.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let rootVC = JUINavigationController.init(rootViewController: ViewController())
        
        //
        
        let window = UIWindow()
        window.frame = UIScreen.main.bounds
        window.backgroundColor = .white
        window.rootViewController = rootVC
        window.makeKeyAndVisible()
        self.window = window
        
        return true
    }
}

class JUINavigationController: UINavigationController {
    override var disablesAutomaticKeyboardDismissal: Bool {
        return false
    }
}

