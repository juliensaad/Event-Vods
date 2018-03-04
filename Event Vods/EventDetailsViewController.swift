//
//  EventDetailsViewController.swift
//  Event Vods
//
//  Created by Julien Saad on 2018-02-17.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit

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
        title = event.name
        view.backgroundColor = UIColor.lolGreen
        view.addSubview(tableView)

        tableView.frame = view.bounds
        view.backgroundColor = UIColor.lolGreen
        tableView.backgroundColor = UIColor.lolGreen
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }

    func presentMatchURL(match: Match, url: String?, placeholder: Bool?) {
        if let placeholder = placeholder {
            if placeholder {
                showPlaceholderAlert()
                return
            }
        }
        if let url = url {
            String.getRedirectURL(url: url, withCompletion: { (string) in
                if let url = string {
                    let playbackViewController = PlaybackViewController(match: match, url: url)
                    self.navigationController?.present(playbackViewController, animated: true, completion: nil)
                }
            })

        }
        else {
            showPlaceholderAlert()
        }
    }

    func showPlaceholderAlert() {
        let alert = UIAlertController(title: NSLocalizedString("sorry", comment: ""),
                                      message: NSLocalizedString("match_doesnt_exist", comment: ""),
                                      preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        present(alert, animated: true, completion: nil)
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
        label.backgroundColor = UIColor.sectionGreen
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
            let picksBans = UIAlertAction(title: "\(prefix)Picks & Bans", style: UIAlertActionStyle.default, handler: { (action) in
                self.presentMatchURL(match: match, url: matchData.youtube?.picksBans, placeholder: matchData.placeholder)
            })

            let gameStart = UIAlertAction(title: "\(prefix)Game Start", style: UIAlertActionStyle.default, handler: { (action) in
                self.presentMatchURL(match: match, url: matchData.youtube?.gameStart, placeholder: matchData.placeholder)
            })

            controller.addAction(picksBans)
            controller.addAction(gameStart)
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
