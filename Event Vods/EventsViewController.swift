//
//  ViewController.swift
//  Event Vods
//
//  Created by Julien Saad on 2018-02-07.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit
import Siesta

class EventsViewController: UIViewController, ResourceObserver {
    
    var events: [Event] = []
    lazy var statusOverlay: ResourceStatusOverlay = {
        let overlay = ResourceStatusOverlay()
        return overlay
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        return tableView
    }()
    
    var eventsResource: Resource? {
        didSet {
            oldValue?.removeObservers(ownedBy: self)
            oldValue?.cancelLoadIfUnobserved(afterDelay: 0.1)

            eventsResource?
                .addObserver(self)
                .addObserver(statusOverlay)
                .loadIfNeeded()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("home", comment: "")
        view.backgroundColor = UIColor(displayP3Red: 19, green: 67, blue: 70, alpha: 1.0)
        view.addSubview(tableView)
        view.addSubview(statusOverlay)
        
        tableView.frame = view.bounds
        statusOverlay.frame = view.bounds
        
        eventsResource = EventAPI.events()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    func resourceChanged(_ resource: Resource, event: ResourceEvent) {
        if resource == eventsResource {
            showEvents(eventsResource?.typedContent())
        }
    }
    
    func showEvents(_ events: [Event]?) {
        guard var events = events else {
            return
        }
        
        
        events = events.filter { (event) -> Bool in
            event.game.slug == Game.LeagueOfLegendsSlug
        }
        
        events.sort { (event, otherEvent) -> Bool in
            if let update = event.updatedAt, let otherUpdate = otherEvent.updatedAt {
                return update > otherUpdate
            }
            return false
        }
        
        self.events = events
        tableView.reloadData()
    }
    
}

// MARK: TableView

extension EventsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = events[indexPath.row]
        let cell = EventCell(event: event, reuseIdentifier: EventTableViewCell.reuseIdentifier)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = events[indexPath.row]

        EventAPI.game(event.slug).addObserver(owner: self) {
            [weak self] resource, _ in
            if let detailedEvent: Event = resource.typedContent() {
                let eventDetailsViewController = EventDetailsViewController(event: detailedEvent)
                self?.navigationController?.pushViewController(eventDetailsViewController, animated: true)
            }

//
        }
        .loadIfNeeded()

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
    }

}
