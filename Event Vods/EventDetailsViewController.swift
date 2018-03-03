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
    let sections: [EventSection]

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
            self.sections = contents.reversed()
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
        return sections[section].modules.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = sections[section]

        let label = UILabel()
        label.text = section.title
        label.backgroundColor = UIColor.lightGray

        return label
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         return 24
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let module = sections[indexPath.section].modules[indexPath.row]
        let cell = UITableViewCell()
        cell.textLabel?.text = module.title

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let module = sections[indexPath.section].modules[indexPath.row]

        guard let match = module.matches2?.first else {
            return
        }

        let playbackViewController = PlaybackViewController(match: match)
        navigationController?.present(playbackViewController, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }

}
