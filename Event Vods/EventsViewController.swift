//
//  ViewController.swift
//  Event Vods
//
//  Created by Julien Saad on 2018-02-07.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit
import Siesta
import SnapKit
import SVProgressHUD

class EventsViewController: UIViewController, ResourceObserver {
    
    var allEvents: [Event] = [] {
        didSet {
            games = Set(allEvents.map({ (event) -> Game in
                return event.game
            }))
        }
    }

    var events: [Event] = []

    var games: Set<Game> = [] {
        didSet {
            print(games)
        }
    }

    var selectedGameSlug = "lol"
    
    lazy var statusOverlay: ResourceStatusOverlay = {
        let overlay = ResourceStatusOverlay()
        return overlay
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.backgroundColor = UIColor.lolGreen
        return tableView
    }()
    
    var eventsResource: Resource? {
        didSet {
            oldValue?.removeObservers(ownedBy: self)
            oldValue?.cancelLoadIfUnobserved(afterDelay: 0.1)

            eventsResource?
                .addObserver(self)
                .loadIfNeeded()
        }
    }

    lazy var logoView: UIButton = {
        let logoView = UIButton()
        logoView.setImage(UIImage(named: "lol"), for: .normal)
        logoView.imageView?.contentMode = .scaleAspectFit
        logoView.imageEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4)
        logoView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        logoView.layer.shadowColor = UIColor.black.cgColor
        logoView.layer.shadowOpacity = 0.2
        logoView.layer.shadowRadius = 6
        logoView.layer.shadowOffset = CGSize(width: 0, height: 1)
        logoView.isUserInteractionEnabled = false
        return logoView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

//        let searchController = UISearchController(searchResultsController: self)
//        searchController.searchBar.tintColor = UIColor.white
//        navigationItem.searchController = searchController
//        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.barTintColor = UIColor.lolGreen
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.addSubview(logoView)
        navigationController?.navigationBar.backgroundColor = UIColor.lolGreen

        logoView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.height.greaterThanOrEqualTo(54)
            make.centerY.equalToSuperview()
        }

        view.backgroundColor = UIColor.lolGreen
        view.addSubview(tableView)
        view.addSubview(statusOverlay)
        
        tableView.frame = view.bounds
        statusOverlay.frame = view.bounds

        eventsResource = EventAPI.events()
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setLogoHidden(true, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLogoHidden(false, animated: true)
    }

    func setLogoHidden(_ hidden: Bool, animated: Bool) {
        if (animated) {
            UIView.animateKeyframes(withDuration: 0.1, delay: 0, options: [], animations: {
                self.logoView.alpha = hidden ? 0 : 1
            }, completion: nil)
        }
        else {
            self.logoView.alpha = hidden ? 0 : 1
        }
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

        events.sort { (event, otherEvent) -> Bool in
            if let update = event.updatedAt, let otherUpdate = otherEvent.updatedAt {
                return update > otherUpdate
            }
            return false
        }

        self.allEvents = events

        filterEvents(selectedGameSlug)
    }

    func filterEvents(_ slug: String) {
        events = allEvents.filter { (event) -> Bool in
            event.game.slug == selectedGameSlug
        }
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
        let cell = EventCell(event: event, reuseIdentifier: EventCell.reuseIdentifier)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let event = events[indexPath.row]

        SVProgressHUD.show()
        EventAPI.game(event.slug).addObserver(owner: self) {
            [weak self] resource, _ in

            if let detailedEvent: Event = resource.typedContent() {
                SVProgressHUD.dismiss()
                let eventDetailsViewController = EventDetailsViewController(event: detailedEvent)
                self?.navigationController?.pushViewController(eventDetailsViewController, animated: true)
                EventAPI.game(event.slug).removeObservers(ownedBy: self)
            }
            else if let error = resource.latestError {
                SVProgressHUD.dismiss()
                print(error)
            }
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
