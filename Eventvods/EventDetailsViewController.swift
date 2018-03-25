//
//  EventDetailsViewController.swift
//  Eventvods
//
//  Created by Julien Saad on 2018-02-17.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit
import Kingfisher
import SafariServices
import SVProgressHUD

class EventDetailsViewController: UIViewController {
    var event: Event
    var sections: [EventModule] = []

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.refreshControl = self.refreshControl
        return tableView
    }()

    private lazy var refreshControl : UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refresh(control:)), for: .valueChanged)
        control.tintColor = UIColor.white
        return control
    }()

    lazy var headerView: DetailsHeaderView = {
        let headerView = DetailsHeaderView(event: event)
        headerView.backButton.addTarget(self, action: #selector(didPressBackButton), for: .touchUpInside)
        return headerView
    }()

    lazy var titleView: UIButton = {
        let titleView = UIButton()
        titleView.contentEdgeInsets = UIEdgeInsetsMake(8,0,8,0)
        titleView.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        titleView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        titleView.setContentHuggingPriority(.defaultLow, for: .vertical)
        titleView.layer.shadowColor = UIColor.black.cgColor
        titleView.layer.shadowOpacity = 0.3
        titleView.layer.shadowRadius = 3
        titleView.layer.shadowOffset = CGSize(width: 0, height: 1)
        titleView.isUserInteractionEnabled = false
        titleView.layer.shouldRasterize = true
        titleView.layer.rasterizationScale = UIScreen.main.scale
        return titleView
    }()

    var gameColor: UIColor {
        return Game.colorForSlug(gameSlug)
    }

    let gameSlug: String

    init(event: Event, gameSlug: String) {
        self.event = event
        self.gameSlug = gameSlug
        super.init(nibName: nil, bundle: nil)
        filterContent()
    }

    @objc func refresh(control: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.reloadMatches()
        }
    }

    func filterContent() {
        if let contents = self.event.contents {
            let fullSections = contents.reversed()

            var dayModules: [EventModule] = []

            for section in fullSections {
                for module in section.modules.reversed() {
                    var newModule = module
                    newModule.title = "\(section.title) - \(module.title)"

                    var newMatches: [Match] = []
                    for match in newModule.matches2 {
                        var shouldAddMatch = false
                        for matchData in match.data {
                            // only show matches that have youtube links
                            // or that are placeholders
                            if matchData.youtube != nil || matchData.twitch != nil {
                                shouldAddMatch = true
                                break
                            }
                        }

                        if shouldAddMatch {
                            newMatches.append(match)
                        }
                    }
                    newModule.matches2 = newMatches
                    if !newModule.matches2.isEmpty {
                        dayModules.append(newModule)
                    }
                }
            }
            sections = dayModules

        }
        else {
            self.sections = []
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = gameColor
        view.addSubview(tableView)
        view.addSubview(headerView)

        headerView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(80)

            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin)
            } else {
                make.top.equalTo(self.view)
            }

        }

        tableView.snp.makeConstraints({ (make) in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
        })

        tableView.backgroundColor = gameColor

        if navigationController?.viewControllers.count == 1 {
            headerView.backButton.isHidden = true
        }

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParentViewController {
            UIView.animate(withDuration: 0.3, animations: {
                self.titleView.alpha = 0
            }) { (completed) in
                self.titleView.removeFromSuperview()
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if UIDevice.current.userInterfaceIdiom == .phone && isMovingFromParentViewController {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.pageController.isSwipingEnabled = true
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if UIDevice.current.userInterfaceIdiom == .phone {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.pageController.isSwipingEnabled = false
            }
        }

        if let logo = event.logo, let url = URL(string:logo) {
            titleView.kf.setImage(with: url, for: .normal, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, type, url) in
                if let image = image {
                    let newImage = self.resizeImageWith(image: image, newSize: CGSize(width: image.size.width / image.size.height * 80, height: 80))
                    self.titleView.setImage(newImage, for: .normal)
                }
            })
            navigationController?.navigationBar.addSubview(titleView)
            
            titleView.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.top.bottom.equalToSuperview().priority(750)
            }
        }
        else {
            title = event.name
        }

        UIView.animate(withDuration: 0.3, animations: {
            self.titleView.alpha = 1
        })

        tableView.reloadData()
        reloadMatches()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3, animations: {
            self.titleView.alpha = 1
        })
    }

    func reloadMatches() {
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
                    sself.event = detailedEvent
                    sself.filterContent()

                    DispatchQueue.main.async {
                        sself.tableView.reloadData()
                        if sself.refreshControl.isRefreshing {
                            sself.refreshControl.endRefreshing()
                        }
                    }
                    EventAPI.game(sself.event.slug).removeObservers(ownedBy: self)
                }
            }
        }.loadIfNeeded()
    }

    @objc func didPressBackButton() {
        navigationController?.popViewController(animated: true)
    }

    func presentMatchURL(match: Match, matchData: MatchData, url: String, time: TimeInterval?, placeholder: Bool?, highlights: Bool) {
        if let placeholder = placeholder {
            if placeholder && !highlights {
                showPlaceholderAlert()
                UserDataManager.shared.saveHighlightsWatched(forMatch: matchData)
                tableView.reloadData()
                return
            }
        }

        SVProgressHUD.show()
        String.getRedirectURL(url: url, withCompletion: { (string) in

            var url: String = url
            if string != nil {
                url = string!
            }

            if url.contains("youtube") || url.contains("youtu.be") {
                SVProgressHUD.dismiss()
                let playbackViewController = PlaybackViewController(match: match, matchData: matchData, url: url, time: time, highlights: highlights)
                self.navigationController?.present(playbackViewController, animated: true, completion: nil)
            }
            else {
                String.getRedirectURL(url: url, withCompletion: { (string) in
                    SVProgressHUD.dismiss()
                    if let string = string {
                        self.handleNonYoutubeURL(url: string)
                    }
                    else {
                        self.handleNonYoutubeURL(url: url)
                    }
                })
            }
        })
    }

    func handleNonYoutubeURL(url: String) {
        if url.count > 0 {

            let apolloBaseScheme = "apollo://"
            if UIApplication.shared.canOpenURL(URL(string: apolloBaseScheme)!) {
                    if let regex = try? NSRegularExpression(pattern: ".+?(?=reddit\\.com)", options: .caseInsensitive) {
                    let range = NSMakeRange(0, url.count)
                    let modString = regex.stringByReplacingMatches(in: url, options: [], range: range, withTemplate: apolloBaseScheme)

                    if let apolloURL = URL(string:modString) {
                        UIApplication.shared.open(apolloURL, options: [:], completionHandler: nil)
                        return;
                    }
                }
            }

            let controller = SFSafariViewController(url: URL(string: url)!)
            self.present(controller, animated: true, completion: nil)


        }
    }

    func showPlaceholderAlert() {
        let alert = MatchAlertController(title: NSLocalizedString("sorry", comment: ""),
                                      message: NSLocalizedString("match_doesnt_exist", comment: ""),
                                      preferredStyle: UIAlertControllerStyle.alert)
        alert.tintColor = gameColor
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func getAction(forTitle title: String, url: String, match: Match, matchData: MatchData, time: TimeInterval?, placeholder: Bool?, highlights: Bool) -> UIAlertAction {
        let action = UIAlertAction(title: title, style: UIAlertActionStyle.default, handler: { (action) in
            self.presentMatchURL(match: match, matchData: matchData, url: url, time: time, placeholder: placeholder, highlights:  highlights)
        })
        return action
    }

    func presentOptions(for matchData: MatchData, match: Match, index: Int, cell: UITableViewCell) {
        var prefix: String = ""
        let hasMultipleMatches = match.data.count > 1
        if hasMultipleMatches {
            prefix = "Game \(index + 1) - "
        }

        let controller = MatchAlertController(title: "\(prefix)\(match.matchTitle)", message: nil, preferredStyle: .actionSheet)
        controller.tintColor = gameColor

        if let url = matchData.youtube?.picksBans {
            let action = getAction(forTitle: "Picks & Bans", url: url, match: match, matchData: matchData, time: nil, placeholder: matchData.placeholder, highlights: false)
            controller.addAction(action)
        }

        if let url = matchData.gameStart {
            let action = getAction(forTitle: "Game Start", url: url, match: match, matchData: matchData, time: nil, placeholder: matchData.placeholder, highlights: false)
            controller.addAction(action)
        }

        if match.highlightsIndex >= 0 && matchData.links.count > match.highlightsIndex {
            if let link = matchData.links[match.highlightsIndex] {
                let action = getAction(forTitle: "Highlights", url: link, match: match, matchData: matchData, time: nil, placeholder: matchData.placeholder, highlights: true)
                controller.addAction(action)
            }
        }

        if !hasMultipleMatches {
            if match.discussionIndex >= 0 && matchData.links.count > match.discussionIndex {
                if let link = matchData.links[match.discussionIndex] {
                    let action = getAction(forTitle: "Discussion", url: link, match: match, matchData: matchData, time: nil, placeholder: matchData.placeholder, highlights: true)
                    controller.addAction(action)
                }
            }
        }

        if let progression = UserDataManager.shared.getProgressionForMatch(match: matchData) {
            var url = matchData.youtube?.gameStart
            if url == nil {
                url = matchData.youtube?.picksBans
            }

            if let url = url {
                let action = getAction(forTitle: "Resume - \(String.fromTimeInterval(progression))", url: url, match: match, matchData: matchData, time: progression, placeholder: matchData.placeholder, highlights: false)
                controller.addAction(action)
            }
        }

        if controller.actions.count == 1 {
            guard let url = matchData.gameStart else {
                return
            }
            presentMatchURL(match: match, matchData: matchData, url: url, time: nil, placeholder: false, highlights: false)
        }
        else {
            let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
            controller.addAction(cancelAction)
            let sourceView = (cell as! MatchTableViewCell).teamMatchupView
            controller.popoverPresentationController?.sourceView = sourceView.vsLabel
            DispatchQueue.main.async {
                self.present(controller, animated: true, completion: nil)
            }
        }
    }

}

// MARK: TableView

extension EventDetailsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].matches2.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = sections[section]

        let label = UIButton()
        label.isUserInteractionEnabled = false
        label.setTitle(section.title, for: .normal)
        label.titleEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        label.backgroundColor = UIColor(red: 0.16, green: 0.14, blue: 0.21, alpha: 1.0)
        label.titleLabel?.font = UIFont.boldVodsFontOfSize(17)
        label.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        let separator = UIView()
        separator.backgroundColor = UIColor(white: 0.1, alpha: 0.4)
        label.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }

        return label
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         return 34
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let match = sections[indexPath.section].matches2[indexPath.row]
        let cell = MatchTableViewCell(match: match, tintColor: gameColor, reuseIdentifier: MatchTableViewCell.reuseIdentifier)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let match = sections[indexPath.section].matches2[indexPath.row]
        let cell = self.tableView.cellForRow(at: indexPath)!
        let controller = MatchAlertController(title: match.matchTitle, message: nil, preferredStyle: .actionSheet)
        controller.tintColor = gameColor
        if match.data.count > 1 {
            for (index, matchData) in match.data.enumerated() {
                var title = "Game \(index+1)\(matchData.watched ? " ✔" : "")"

                if matchData.isComingSoon {
                    title += " - Soon™"
                }

                let action = UIAlertAction(title: title, style: .default, handler: { (action) in
                    self.presentOptions(for: matchData, match: match, index: index, cell: cell)
                })

                if matchData.isComingSoon {
                    action.isEnabled = false
                }

                controller.addAction(action)

                if match.discussionIndex >= 0 && matchData.links.count > match.discussionIndex {
                    if let link = matchData.links[match.discussionIndex] {
                        let action = getAction(forTitle: "Discussion", url: link, match: match, matchData: matchData, time: nil, placeholder: matchData.placeholder, highlights: true)
                        controller.addAction(action)
                    }
                }
            }
        }
        else if match.data.count == 1 {
            self.presentOptions(for: match.data[0], match: match, index: 0, cell: cell)
            return;
        }

        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
        controller.addAction(cancelAction)

        let sourceView = (cell as! MatchTableViewCell).teamMatchupView
        controller.popoverPresentationController?.sourceView = sourceView.vsLabel
        DispatchQueue.main.async {
            self.present(controller, animated: true, completion: nil)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let match = sections[indexPath.section].matches2[indexPath.row]
        if match.title != nil {
            return 110 + MatchTableViewCell.matchTitleHeight
        }
        return 110
    }

    func resizeImageWith(image: UIImage, newSize: CGSize) -> UIImage {

        let horizontalRatio = newSize.width / image.size.width
        let verticalRatio = newSize.height / image.size.height

        let ratio = max(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
        var newImage: UIImage

        let renderFormat = UIGraphicsImageRendererFormat.default()
        renderFormat.opaque = false
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: newSize.width, height: newSize.height), format: renderFormat)
        newImage = renderer.image {
            (context) in
            image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        }

        return newImage
    }

}
