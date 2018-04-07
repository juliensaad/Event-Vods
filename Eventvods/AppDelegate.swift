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
import GoogleCast

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GCKLoggerDelegate {

    var window: UIWindow?
    let pageController = YZSwipeBetweenViewController()

    func setSwipingEnabled(_ enabled: Bool) {
        pageController.isSwipingEnabled = enabled
    }

    func applicationDidFinishLaunching(_ application: UIApplication) {
        Fabric.with([Crashlytics.self])
        PlayerViewManager.shared.prepare()

        setupGoogleCast();

        UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).tintColor = UIColor.white

        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)

        let gameIndex = UserDataManager.shared.getGameIndex()
        let currentGameSlug = Game.orderedGames.remove(at: gameIndex)
        Game.orderedGames.insert(currentGameSlug, at: 0)

        for slug in Game.orderedGames {
            if UIDevice.current.userInterfaceIdiom == .pad {
                let splitViewController = EventsSplitViewController(slug: slug)
                pageController.viewControllers.append(splitViewController)
            }
            else {
                let viewController = EventsViewController(slug: slug)
                let navigationController = UINavigationController(rootViewController: viewController)
                if #available(iOS 11.0, *) {
                    navigationController.navigationBar.prefersLargeTitles = true
                }
                pageController.viewControllers.append(navigationController)
            }
        }


        window?.rootViewController = pageController
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

    func logMessage(_ message: String, at level: GCKLoggerLevel, fromFunction function: String, location: String) {
        print("\(message) \(function)")
    }

    func setupGoogleCast() {
        let criteria = GCKDiscoveryCriteria(applicationID: "4F8B3483")
        let options = GCKCastOptions(discoveryCriteria: criteria)
        GCKCastContext.setSharedInstanceWith(options)
        GCKLogger.sharedInstance().delegate = self
        GCKLogger.sharedInstance().minimumLevel = .verbose;
    }
}

