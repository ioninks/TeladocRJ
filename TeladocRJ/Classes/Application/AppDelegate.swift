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
    
    let fileURL = Bundle.main.url(forResource: "Romeo-and-Juliet", withExtension: "txt")!
    let viewModel = WordFrequenciesListViewModel(
      fileURL: fileURL,
      dependencies: .init(
        fileReaderService: FileReaderService(),
        wordsCounterService: WordsCounterService(),
        wordsSortingService: WordsSortingService()
      )
    )
    let viewController = WordFrequenciesListViewController(viewModel: viewModel)
    self.window?.rootViewController = viewController
    
    self.window?.makeKeyAndVisible()
    
    return true
  }

}

