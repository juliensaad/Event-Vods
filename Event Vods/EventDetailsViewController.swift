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

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        return tableView
    }()

    init(event: Event) {
        self.event = event
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
}

// MARK: TableView

extension EventDetailsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return event.contents?.count ?? 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = event.contents?[section] else {
            return 0
        }

//        let matchCount = section.modules?.map({ (module) -> Int in
//            return module.matches.count
//        }).reduce(0) { $0 + $1 }
        return section.modules?.count ?? 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = event.contents?[section] else {
            return nil
        }

        let label = UILabel()
        label.text = section.title
        label.backgroundColor = UIColor.lightGray

        return label
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         return 24
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let module = event.contents?[indexPath.section].modules?[indexPath.row] else {
            return UITableViewCell()
        }

        let cell = UITableViewCell()
        cell.textLabel?.text = module.title

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let module = event.contents?[indexPath.section].modules?[indexPath.row] else {
            return
        }

        guard let urlString = module.matches2.first?.data?.first?.youtube.gameStart else {
            return
        }

        let playbackViewController = PlaybackViewController(url: urlString)
        navigationController?.present(playbackViewController, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }

}
