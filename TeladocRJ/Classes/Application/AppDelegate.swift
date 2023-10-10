//
//  AppDelegate.swift
//  TeladocRJ
//
//  Created by Konstantin Ionin on 10.10.2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    self.window = UIWindow(frame: UIScreen.main.bounds)
    
    let viewController = ViewController(nibName: nil, bundle: nil)
    self.window?.rootViewController = viewController
    
    self.window?.makeKeyAndVisible()
    
    return true
  }

}

