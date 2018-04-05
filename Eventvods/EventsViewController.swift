//
//  ViewController.swift
//  Eventvods
//
//  Created by Julien Saad on 2018-02-07.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit
import Siesta
import SnapKit
import SVProgressHUD

protocol EventsViewControllerDelegate: NSObjectProtocol {
    func eventsViewController(_ viewController: EventsViewController, didSelectEvent event: Event)
}

class EventsViewController: UIViewController, ResourceObserver {

    weak var delegate: EventsViewControllerDelegate?

    var textFilter: String = ""
    var events: [Event] = []
    var shouldEndRefreshing = false
    var didBeginRefreshing = false
    let selectedGameSlug: String
    var currentOffset: CGFloat = 0

    var allEvents: [Event] = [] {
        didSet {
            games = Set(allEvents.map({ (event) -> Game in
                return event.game
            }))
        }
    }

    var games: Set<Game> = []
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.backgroundColor = Game.colorForSlug(selectedGameSlug)
        tableView.refreshControl = self.refreshControl
        tableView.alwaysBounceVertical = true
        return tableView
    }()

    private lazy var headerView: HomeHeaderView = {
        let header = HomeHeaderView(slug: self.selectedGameSlug)
        header.delegate = self
        return header
    }()

    private lazy var refreshControl : UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refresh(control:)), for: .valueChanged)
        control.tintColor = UIColor.white
        return control
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

    init(slug: String) {
        self.selectedGameSlug = slug
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        self.selectedGameSlug = ""
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        SVProgressHUD.show()

        navigationController?.navigationBar.isTranslucent = false

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        }
        navigationController?.navigationBar.isHidden = true
        view.addSubview(headerView)
        view.backgroundColor = Game.colorForSlug(selectedGameSlug)
        view.addSubview(tableView)

        headerView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin)
            }
            else {
                make.top.equalTo(self.view.snp.topMargin)
            }
        }

        tableView.snp.makeConstraints({ (make) in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
        })

        eventsResource = EventAPI.events()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        headerView.resignFirstResponder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        headerView.setLogoHidden(false, animated: true)
        headerView.reloadArrowViews(hidden: false, viewController: self)

        if let resource = eventsResource {
            resource.loadIfNeeded()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let currentIndex = appDelegate.pageController.index(of: self)
            UserDataManager.shared.saveGameIndex(index: currentIndex)
        }

        headerView.setLogoHidden(false, animated: true)
        headerView.reloadArrowViews(hidden: false, viewController: self)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        headerView.setLogoHidden(true, animated: true)
        headerView.reloadArrowViews(hidden: true, viewController: self)
    }

    @objc func refresh(control: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.eventsResource?.load()
            self.didBeginRefreshing = true
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

        SVProgressHUD.dismiss()

        events.sort { (event, otherEvent) -> Bool in
            if let update = event.updatedAt, let otherUpdate = otherEvent.updatedAt {
                return update > otherUpdate
            }
            return false
        }

        self.allEvents = events

        filterEvents()
    }

    func filterEvents() {
        events = allEvents.filter { (event) -> Bool in
            if event.game.slug == selectedGameSlug || selectedGameSlug.isEmpty {
                if let status = event.status, status.lowercased() != "upcoming" {
                    return true
                }
            }
            return false
        }

        if textFilter.count > 0 {
            events = events.filter({ (event) -> Bool in
                if event.name.lowercased().contains(textFilter.lowercased()) ||
                    event.game.slug.lowercased().contains(textFilter.lowercased()) {
                    return true
                }
                return false
            })
        }

        tableView.reloadData()

        if UIDevice.current.userInterfaceIdiom == .pad {
            if events.count > 0 {
                tableView(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
            }
        }

        DispatchQueue.main.async {
            if self.refreshControl.isRefreshing {
                if !self.tableView.isDragging {
                    self.refreshControl.endRefreshing()
                    self.didBeginRefreshing = false
                }
                else {
                    self.shouldEndRefreshing = true
                }
            }
        }
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
        if UIDevice.current.userInterfaceIdiom == .phone {
            tableView.deselectRow(at: indexPath, animated: true)
        }

        let event = events[indexPath.row]
        
        SVProgressHUD.show()
        EventAPI.game(event.slug).addObserver(owner: self) {
            [weak self] resource, _ in

            if let detailedEvent: Event = resource.typedContent() {
                SVProgressHUD.dismiss()

                if let contents = detailedEvent.contents {
                    for section in contents {
                        for module in section.modules {
                            for match in module.matches2 {
                                match.gameSlug = detailedEvent.game.slug
                            }
                        }
                    }
                }

                if let sself = self {
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        sself.delegate?.eventsViewController(sself, didSelectEvent: detailedEvent)
                    }
                    else {
                        let eventDetailsViewController = EventDetailsViewController(event: detailedEvent, gameSlug: detailedEvent.game.slug)
                        sself.headerView.setLogoHidden(true, animated: true)
                        sself.headerView.reloadArrowViews(hidden: true, viewController: sself)
                        sself.navigationController?.pushViewController(eventDetailsViewController, animated: true)
                    }
                }

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

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if shouldEndRefreshing {
            refreshControl.endRefreshing()
            shouldEndRefreshing = false
            didBeginRefreshing = false
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        headerView.resignFirstResponder()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let searchBarHeight = HomeHeaderView.searchBarHeight
//        if currentOffset < searchBarHeight && scrollView.contentOffset.y >= 0 {
//            currentOffset += scrollView.contentOffset.y
//            scrollView.contentOffset.y = 0
//            if (searchBarHeight - currentOffset > 0) {
//                headerView.searchBarHeightConstraint.update(offset: searchBarHeight - currentOffset)
//            }
//            else {
//                headerView.searchBarHeightConstraint.update(offset: 0)
//                currentOffset = searchBarHeight
//            }
//        }
//        else if currentOffset >= searchBarHeight && scrollView.contentOffset.y > 0 {
//            headerView.searchBarHeightConstraint.update(offset: 0)
//        }
//        else if currentOffset <= searchBarHeight && currentOffset > 0 && scrollView.contentOffset.y <= 0 {
//            currentOffset += scrollView.contentOffset.y
//            scrollView.contentOffset.y = 0
//            if (currentOffset <= searchBarHeight && currentOffset > 0) {
//                headerView.searchBarHeightConstraint.update(offset: searchBarHeight - currentOffset)
//            }
//            else {
//                currentOffset = 0
//                headerView.searchBarHeightConstraint.update(offset: searchBarHeight)
//            }
//        }
    }
}

extension EventsViewController: HomeHeaderViewDelegate {
    func headerViewDidTapLeftArrow(_ headerView: HomeHeaderView) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let currentIndex = appDelegate.pageController.currentIndex
        appDelegate.pageController.setCurrentIndex(currentIndex - 1, animated: true)
    }

    func headerViewDidTapRightArrow(_ headerView: HomeHeaderView) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let currentIndex = appDelegate.pageController.currentIndex
        appDelegate.pageController.setCurrentIndex(currentIndex + 1, animated: true)
    }

    func headerViewTextDidChange(_ headerView: HomeHeaderView, text: String) {
        textFilter = text
        filterEvents()
    }
}
