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
                    var shouldAddMatch = false
                    for match in newModule.matches2 {
                        for matchData in match.data {
                            // only show matches that have youtube links
                            // or that are placeholders
                            if matchData.youtube != nil || matchData.placeholder == true {
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
        navigationItem.largeTitleDisplayMode = UINavigationItem.LargeTitleDisplayMode.never

        let titleView = UIButton()
        if let logo = event.logo, let url = URL(string:logo) {
            titleView.kf.setImage(with: url, for: .normal)
            titleView.imageEdgeInsets = UIEdgeInsetsMake(8,8,8,8)
            titleView.imageView?.contentMode = UIViewContentMode.scaleAspectFit
            titleView.layer.shadowColor = UIColor.black.cgColor
            titleView.layer.shadowOpacity = 0.3
            titleView.layer.shadowRadius = 3
            titleView.layer.shadowOffset = CGSize(width: 0, height: 1)
            titleView.isUserInteractionEnabled = false
            navigationItem.titleView = titleView
        }
        else {
            title = event.name
        }

        navigationController?.navigationBar.topItem?.title = ""

        view.backgroundColor = UIColor.black
        view.addSubview(tableView)

        tableView.frame = view.bounds
        tableView.backgroundColor = UIColor.clear

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
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
        label.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.22, alpha: 1.0)
        label.titleLabel?.font = UIFont(name: "Avenir", size: 16)

        return label
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         return 30
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let match = sections[indexPath.section].matches2[indexPath.row]
        let cell = MatchTableViewCell(match: match, reuseIdentifier: MatchTableViewCell.reuseIdentifier)
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

        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
        controller.addAction(cancelAction)

        let sourceView = (self.tableView.cellForRow(at: indexPath) as! MatchTableViewCell).teamMatchupView
        controller.popoverPresentationController?.sourceView = sourceView.vsLabel
        DispatchQueue.main.async {
            self.present(controller, animated: true, completion: nil)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }

}
