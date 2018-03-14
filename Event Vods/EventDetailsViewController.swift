//
//  EventDetailsViewController.swift
//  Event Vods
//
//  Created by Julien Saad on 2018-02-17.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit
import Kingfisher

class EventDetailsViewController: UIViewController {
    let event: Event
    let sections: [EventModule]

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        return tableView
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
        return navigationController?.navigationBar.backgroundColor ?? UIColor.lolGreen
    }

    init(event: Event) {
        self.event = event
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
                            if matchData.youtube != nil {
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
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()



        view.backgroundColor = gameColor
        view.addSubview(tableView)

        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        tableView.backgroundColor = UIColor.clear
        navigationController?.navigationBar.topItem?.title = ""

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
    }

    func presentMatchURL(match: Match, matchData: MatchData, url: String, time: TimeInterval?, placeholder: Bool?) {
        if let placeholder = placeholder {
            if placeholder {
                showPlaceholderAlert()
                return
            }
        }

        String.getRedirectURL(url: url, withCompletion: { (string) in
            if let url = string {
                let playbackViewController = PlaybackViewController(match: match, matchData: matchData, url: url, time: time)
                self.navigationController?.present(playbackViewController, animated: true, completion: nil)
            }
        })
    }

    func showPlaceholderAlert() {
        let alert = UIAlertController(title: NSLocalizedString("sorry", comment: ""),
                                      message: NSLocalizedString("match_doesnt_exist", comment: ""),
                                      preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func getAction(forTitle title: String, url: String, match: Match, matchData: MatchData, time: TimeInterval?, placeholder: Bool?) -> UIAlertAction {
        return UIAlertAction(title: title, style: UIAlertActionStyle.default, handler: { (action) in
            self.presentMatchURL(match: match, matchData: matchData, url: url, time: time, placeholder: placeholder)
        })
    }

    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
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

        let controller = UIAlertController(title: match.matchTitle, message: nil, preferredStyle: .actionSheet)

        var prefix: String = ""

        for (index, matchData) in match.data.enumerated() {
            if match.data.count > 1 {
                prefix = "Game \(index+1) - "
            }

            if let url = matchData.youtube?.picksBans {
                let action = getAction(forTitle: "\(prefix)Picks & Bans", url: url, match: match, matchData: matchData, time: nil, placeholder: matchData.placeholder)
                controller.addAction(action)
            }

            if let url = matchData.youtube?.gameStart {
                let action = getAction(forTitle: "\(prefix)Game Start", url: url, match: match, matchData: matchData, time: nil, placeholder: matchData.placeholder)
                controller.addAction(action)
            }

            if let progression = UserDataManager.shared.getProgressionForMatch(match: matchData) {
                var url = matchData.youtube?.gameStart
                if url == nil {
                    url = matchData.youtube?.picksBans
                }

                if let url = url {
                    let action = getAction(forTitle: "\(prefix)Resume - \(stringFromTimeInterval(interval: progression))", url: url, match: match, matchData: matchData, time: progression, placeholder: matchData.placeholder)
                    controller.addAction(action)
                }
            }

        }

        if controller.actions.count == 1 {
            guard let youtube = match.data[0].youtube else {
                return
            }
            if let onlyValidUrl = youtube.validUrl {
                presentMatchURL(match: match, matchData: match.data[0], url: onlyValidUrl, time: nil, placeholder: false)
            }
        }
        else {
            let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
            controller.addAction(cancelAction)

            let sourceView = (self.tableView.cellForRow(at: indexPath) as! MatchTableViewCell).teamMatchupView
            controller.popoverPresentationController?.sourceView = sourceView.vsLabel
            DispatchQueue.main.async {
                self.present(controller, animated: true, completion: nil)
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
