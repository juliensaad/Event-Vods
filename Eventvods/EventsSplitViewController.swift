//
//  EventsSplitViewController.swift
//  Eventvods
//
//  Created by Julien Saad on 2018-03-10.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit

class EventsSplitViewController: UISplitViewController, EventsViewControllerDelegate {

    let eventsViewController: EventsViewController
    let rootViewController: UINavigationController

    init(slug: String) {
        eventsViewController = EventsViewController(slug: slug)
        rootViewController = UINavigationController(rootViewController: eventsViewController)
        rootViewController.navigationBar.prefersLargeTitles = true

        let placeholderViewController = UIViewController()
        placeholderViewController.view.backgroundColor = Game.colorForSlug(slug)
        super.init(nibName: nil, bundle: nil)
        preferredDisplayMode = .allVisible
        viewControllers = [rootViewController, placeholderViewController]
        eventsViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("IB not supported")
    }

    func eventsViewController(_ viewController: EventsViewController, didSelectEvent event: Event) {
        let detailViewController = UINavigationController(rootViewController: EventDetailsViewController(event: event))
        detailViewController.navigationBar.prefersLargeTitles = true
        detailViewController.navigationBar.backgroundColor = viewController.navigationController?.navigationBar.backgroundColor
        detailViewController.navigationBar.barTintColor = detailViewController.navigationBar.backgroundColor

        viewControllers = [rootViewController, detailViewController]
    }

}
