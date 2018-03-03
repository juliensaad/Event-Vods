//
//  MatchTableViewCell.swift
//  Event Vods
//
//  Created by Julien Saad on 2018-03-03.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit

class MatchTableViewCell: UITableViewCell {

    static let reuseIdentifier = "MatchTableViewCell"

    private lazy var teamMatchupView: TeamMatchupView = {
        let view = TeamMatchupView()
        return view
    }()

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        // do nothing
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        // do nothing
    }

    init(match: Match, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        teamMatchupView.match = match
        contentView.backgroundColor = UIColor.lolGreen
        contentView.addSubview(teamMatchupView)

        teamMatchupView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
            make.centerY.equalToSuperview()
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("IB not supported")
    }

    func makeCard() {
        //
        //        card.backgroundColor = UIColor(red: 0, green: 94/255, blue: 112/255, alpha: 1)
        //        card.icon = UIImage(named: "flappy")
        //        card.title = event.name
        //        card.itemTitle = event.slug
        //        card.itemSubtitle = event.startDate?.description ?? ""
        //        card.textColor = UIColor.white
        //
        //        card.hasParallax = true
        //
        //        card.snp.makeConstraints { (make) in
        //            make.edges.equalTo(contentView).inset(UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20))
        //        }
    }

}

