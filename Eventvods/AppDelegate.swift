    //
//  AppDelegate.swift
//  Eventvods
//
//  Created by Julien Saad on 2018-02-07.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit
import SVProgressHUD
import Fabric
import Crashlytics
import ABVolumeControl

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let pageController = YZSwipeBetweenViewController()
    var tabBarController: TabBarController!

    func applicationDidFinishLaunching(_ application: UIApplication) {
        Fabric.with([Crashlytics.self])
        PlayerViewManager.shared.prepare()
        UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).tintColor = UIColor.white

        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)

        tabBarController = TabBarController(pageController: pageController)
        window?.rootViewController = tabBarController
    }
    
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return true
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            if let navigationController = pageController.visibleViewController as? UINavigationController {
                if navigationController.visibleViewController is PlaybackViewController {
                    return [.landscapeRight, .landscapeLeft, .portrait]
                } else {
                    return [.portrait]
                }
            }
            return [.portrait]
        }
        else {
            return [.landscapeLeft, .landscapeRight]
        }
    }

    func setSwipingEnabled(_ enabled: Bool) {
        pageController.isSwipingEnabled = enabled
    }
}

