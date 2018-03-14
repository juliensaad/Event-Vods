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

    var games: Set<Game> = [] {
        didSet {
            print(games)
        }
    }

    var selectedGameSlug = "lol"
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.backgroundColor = Game.colorForSlug(selectedGameSlug)
        return tableView
    }()

    private lazy var refreshControl : UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refresh(control:)), for: .valueChanged)
        return control
    }()

    private lazy var rightArrow: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"right-1"), for: .normal)
        button.alpha = 0.6
        button.addTarget(self, action: #selector(tapArrowView(button:)), for: .touchUpInside)
        return button
    }()

    private lazy var leftArrow: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"left-1"), for: .normal)
        button.alpha = 0.6
        button.addTarget(self, action: #selector(tapArrowView(button:)), for: .touchUpInside)
        return button
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
        logoView.setImage(UIImage(named: selectedGameSlug), for: .normal)
        logoView.imageView?.contentMode = .scaleAspectFit
        logoView.imageEdgeInsets = UIEdgeInsetsMake(12, 4, 12, 4)
        logoView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        logoView.layer.shadowColor = UIColor.black.cgColor
        logoView.layer.shadowOpacity = 0.2
        logoView.layer.shadowRadius = 6
        logoView.layer.shadowOffset = CGSize(width: 0, height: 1)
        logoView.isUserInteractionEnabled = false
        logoView.layer.shouldRasterize = true
        logoView.layer.rasterizationScale = UIScreen.main.scale
        return logoView
    }()

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
        navigationController?.navigationBar.barTintColor = Game.colorForSlug(selectedGameSlug)
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.addSubview(logoView)
        navigationController?.navigationBar.addSubview(rightArrow)
        navigationController?.navigationBar.addSubview(leftArrow)
        navigationController?.navigationBar.backgroundColor = Game.colorForSlug(selectedGameSlug)

        logoView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.height.greaterThanOrEqualTo(54)
            make.centerY.equalToSuperview()
        }

        rightArrow.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(10)
        }

        leftArrow.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(10)
        }

        view.backgroundColor = Game.colorForSlug(selectedGameSlug)
        view.addSubview(tableView)

        tableView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })

        eventsResource = EventAPI.events()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLogoHidden(false, animated: true)
        reloadArrowViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setLogoHidden(false, animated: true)
        reloadArrowViews()
    }

    func reloadArrowViews() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let currentIndex = appDelegate.pageController.currentIndex
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
        eventsResource?.load()
    }

    @objc func tapArrowView(button: UIButton) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let currentIndex = appDelegate.pageController.currentIndex
        if button == rightArrow {
            appDelegate.pageController.setCurrentIndex(currentIndex + 1, animated: true)
        }
        else {
            appDelegate.pageController.setCurrentIndex(currentIndex - 1, animated: true)
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
            if !resource.isLoading {
                refreshControl.endRefreshing()
            }
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

}

extension EventsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("change");
    }
}
