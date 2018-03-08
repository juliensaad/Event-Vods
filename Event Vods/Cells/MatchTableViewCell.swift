//
//  MatchTableViewCell.swift
//  Event Vods
//
//  Created by Julien Saad on 2018-03-03.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit
import Kingfisher

class MatchTableViewCell: UITableViewCell {

    static let reuseIdentifier = "MatchTableViewCell"

    lazy var teamMatchupView: TeamMatchupView = {
        let view = TeamMatchupView()
        return view
    }()

    lazy var backgroundImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = UIViewContentMode.scaleAspectFill
        view.alpha = 0.1
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

        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(white: 0.1, alpha: 0.4)

        teamMatchupView.match = match
        backgroundColor = .clear
        contentView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.11, alpha: 0.9)
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(teamMatchupView)
        contentView.addSubview(separatorView)

        backgroundImageView.image = UIImage(named: match.backgroundImageName)
        backgroundImageView.clipsToBounds = true
        backgroundImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        separatorView.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.left.right.bottom.equalToSuperview()
        }

        teamMatchupView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("IB not supported")
    }

}

