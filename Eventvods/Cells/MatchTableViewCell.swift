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
        view.alpha = 0.2
        return view
    }()

    lazy var overlay: UIView = {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = UIColor.black
        return view
    }()

    lazy var watchCountButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.boldVodsFontOfSize(18)
        button.setTitleColor(UIColor.white, for: .normal)
        return button
    }()

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.overlay.alpha = 0.4
        }
        else {
            self.overlay.alpha = 0
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        // do nothing
    }

    init(match: Match, tintColor: UIColor, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(white: 0.1, alpha: 0.4)

        teamMatchupView.match = match
        
        backgroundColor = .clear
        contentView.backgroundColor = tintColor
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(teamMatchupView)
        contentView.addSubview(separatorView)
        contentView.addSubview(watchCountButton)
        contentView.addSubview(overlay)

        backgroundImageView.image = UIImage(named: match.backgroundImageName)
        backgroundImageView.clipsToBounds = true
        backgroundImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        overlay.snp.makeConstraints { (make) in
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

        watchCountButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-22)
            make.centerY.equalToSuperview()
        }

        if match.isFullyWatched {
            watchCountButton.setTitle("\(match.watchCount)/\(match.data.count)", for: .normal)
//            watchCountButton.setImage(UIImage(named:"watched"), for: .normal)
            teamMatchupView.alpha = 0.4
            watchCountButton.alpha = 0.4
        }
        else {
            watchCountButton.setTitle("\(match.watchCount)/\(match.data.count)", for: .normal)
            watchCountButton.alpha = 1.0
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("IB not supported")
    }

}

