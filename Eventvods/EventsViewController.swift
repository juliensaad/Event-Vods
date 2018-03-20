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

    var allEvents: [Event] = [] {
        didSet {
            games = Set(allEvents.map({ (event) -> Game in
                return event.game
            }))
        }
    }

    var events: [Event] = []
    var shouldEndRefreshing = false
    var didBeginRefreshing = false

    var games: Set<Game> = [] {
        didSet {
            print(games)
        }
    }

    var leftArrow: UIButton {
        return headerView.leftArrow
    }

    var rightArrow: UIButton {
        return headerView.rightArrow
    }
    var logoView: UIButton {
        return headerView.logoView
    }

    var selectedGameSlug = "lol"
    
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
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        SVProgressHUD.show()
//        let searchController = UISearchController(searchResultsController: nil)
//        searchController.searchBar.delegate = self
//        searchController.searchBar.tintColor = UIColor.white
//        navigationItem.searchController = searchController
//        navigationItem.hidesSearchBarWhenScrolling = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isHidden = true
//        navigationController?.navigationBar.barTintColor = Game.colorForSlug(selectedGameSlug)
//        navigationController?.navigationBar.tintColor = UIColor.white
//        navigationController?.navigationBar.addSubview(logoView)
//        navigationController?.navigationBar.addSubview(rightArrow)
//        navigationController?.navigationBar.addSubview(leftArrow)
//        navigationController?.navigationBar.backgroundColor = Game.colorForSlug(selectedGameSlug)



        view.addSubview(headerView)
        view.backgroundColor = Game.colorForSlug(selectedGameSlug)
        view.addSubview(tableView)

        headerView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(80)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin)
        }

        tableView.snp.makeConstraints({ (make) in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
        })

        eventsResource = EventAPI.events()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLogoHidden(false, animated: true)
        reloadArrowViews(hidden: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setLogoHidden(false, animated: true)
        reloadArrowViews(hidden: false)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        setLogoHidden(true, animated: true)
        reloadArrowViews(hidden: true)
    }

    func reloadArrowViews(hidden: Bool) {
        if hidden {
            leftArrow.isHidden = true
            rightArrow.isHidden = true
        }
        else if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let currentIndex = appDelegate.pageController.index(of: self)
            let lastIndex = appDelegate.pageController.viewControllers.count - 1
            leftArrow.isHidden = false
            rightArrow.isHidden = false
            if currentIndex == 0 {
                leftArrow.isHidden = true
            }
            else if currentIndex == lastIndex {
                rightArrow.isHidden = true
            }
        }
    }

    @objc func refresh(control: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.eventsResource?.load()
            self.didBeginRefreshing = true
        }
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

        SVProgressHUD.dismiss()

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
        tableView.deselectRow(at: indexPath, animated: true)

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
                                if let slug = self?.selectedGameSlug {
                                    match.gameSlug = slug
                                }
                            }
                        }
                    }
                }

                if UIDevice.current.userInterfaceIdiom == .pad {
                    if let sself = self {
                        sself.delegate?.eventsViewController(sself, didSelectEvent: detailedEvent)
                    }
                }
                else {
                    let eventDetailsViewController = EventDetailsViewController(event: detailedEvent)
                    self?.setLogoHidden(true, animated: true)
                    self?.reloadArrowViews(hidden: true)
                    self?.navigationController?.pushViewController(eventDetailsViewController, animated: true)
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

}

extension EventsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("change");
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
}
