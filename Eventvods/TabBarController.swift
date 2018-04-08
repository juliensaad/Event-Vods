//
//  TabBarController.swift
//  Eventvods
//
//  Created by Julien Saad on 2018-04-08.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    init(pageController: YZSwipeBetweenViewController) {
        let gameIndex = UserDataManager.shared.getGameIndex()
        let currentGameSlug = Game.orderedGames.remove(at: gameIndex)
        Game.orderedGames.insert(currentGameSlug, at: 0)



        UITabBar.appearance().barTintColor = UIColor.lolGreen
        UITabBar.appearance().tintColor = UIColor.white
        UITabBar.appearance().isOpaque = true

        super.init(nibName: nil, bundle: nil)

        for slug in Game.orderedGames {
            let eventsViewController = getEventsControllerContainer(slug: slug)
            pageController.viewControllers.append(eventsViewController)
        }

        let profileController = UIViewController()
        let homeItem = UITabBarItem(title: NSLocalizedString("home", comment: ""), image: UIImage(named: "home"), selectedImage: UIImage(named: "home"))
        pageController.tabBarItem = homeItem

        let profileItem = UITabBarItem(title: NSLocalizedString("profile", comment: ""), image: UIImage(named: "user"), selectedImage: UIImage(named: "user"))
        profileController.tabBarItem = profileItem

        let favoritesController = getEventsControllerContainer(slug: "")
        let favoritesItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.favorites, tag: 0)
        favoritesController.tabBarItem = favoritesItem

        favoritesController.extendedLayoutIncludesOpaqueBars = true
        pageController.extendedLayoutIncludesOpaqueBars = true
        profileController.extendedLayoutIncludesOpaqueBars = true
        self.addChildViewController(pageController)
        self.addChildViewController(favoritesController)
        self.addChildViewController(profileController)

        self.tabBar.unselectedItemTintColor = UIColor(white: 1.0, alpha: 0.4)
        self.tabBar.isOpaque = true
        self.tabBar.isTranslucent = false
    }

    func getEventsControllerContainer(slug: String) -> UIViewController {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let splitViewController = EventsSplitViewController(slug: slug)
            return splitViewController
        }
        else {
            let viewController = EventsViewController(slug: slug)
            let navigationController = UINavigationController(rootViewController: viewController)
            if #available(iOS 11.0, *) {
                navigationController.navigationBar.prefersLargeTitles = true
            }
            return navigationController
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
