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
                for module in section.modules {
                    var newModule = module
                    newModule.title = "\(section.title) - \(module.title)"
                    dayModules.append(newModule)
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
}

// MARK: TableView

extension EventDetailsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

//        let matchCount = section.modules?.map({ (module) -> Int in
//            return module.matches.count
//        }).reduce(0) { $0 + $1 }
        return sections[section].matches2.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = sections[section]

        let label = UIButton()
        label.isUserInteractionEnabled = false
        label.setTitle(section.title, for: .normal)
        label.titleEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        label.backgroundColor = UIColor.sectionGreen

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
        let playbackViewController = PlaybackViewController(match: match)
        navigationController?.present(playbackViewController, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

}
