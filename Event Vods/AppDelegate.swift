    //
//  AppDelegate.swift
//  Event Vods
//
//  Created by Julien Saad on 2018-02-07.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit
import SVProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let pageController = YZSwipeBetweenViewController()

    func setSwipingEnabled(_ enabled: Bool) {
        pageController.isSwipingEnabled = enabled
    }

    func applicationDidFinishLaunching(_ application: UIApplication) {
        for slug in ["lol", "csgo", "overwatch", "dota", "rocket-league"] {
            let viewController = EventsViewController(slug: slug)
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.navigationBar.prefersLargeTitles = true
            pageController.viewControllers.append(navigationController)
        }

        window?.rootViewController = pageController
    }
    
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return true
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if let navigationController = self.window?.rootViewController as? UINavigationController {
            if navigationController.visibleViewController is PlaybackViewController {
                return [.portrait, .landscapeLeft, .landscapeRight]
            } else {
                return .portrait
            }
        }
        return .portrait
    }


}

