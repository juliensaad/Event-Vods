//
//  MatchTableViewCell.swift
//  Eventvods
//
//  Created by Julien Saad on 2018-03-03.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit
import Kingfisher

class MatchTableViewCell: UITableViewCell {
    static let matchTitleHeight: CGFloat = 34
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

    lazy var gradientView: GradientView = {
        let view = GradientView()
        view.backgroundColor = .clear
        view.startColor = UIColor(white: 0, alpha: 0.4)
        view.endColor = UIColor(white: 0, alpha: 0.6)
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

    private lazy var matchTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.boldVodsFontOfSize(18)
        label.backgroundColor = UIColor(white: 0, alpha: 0.2)
        return label
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

        accessibilityIdentifier = reuseIdentifier
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(white: 0.1, alpha: 0.4)

        teamMatchupView.match = match
        
        backgroundColor = .clear
        contentView.backgroundColor = tintColor
        contentView.addSubview(backgroundImageView)
//        contentView.addSubview(gradientView)
        contentView.addSubview(teamMatchupView)
        contentView.addSubview(separatorView)
        contentView.addSubview(watchCountButton)
        contentView.addSubview(overlay)
        contentView.addSubview(matchTitleLabel)

        let shouldShowMatchTitle = (match.title != nil)
        backgroundImageView.image = UIImage(named: match.backgroundImageName)
        backgroundImageView.clipsToBounds = true
        backgroundImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        overlay.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.top.equalTo(matchTitleLabel.snp.bottom)
        }

//        gradientView.snp.makeConstraints { (make) in
//            make.edges.equalTo(overlay)
//        }

        separatorView.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.left.right.bottom.equalToSuperview()
        }

        teamMatchupView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.centerY.equalToSuperview().offset(shouldShowMatchTitle ? MatchTableViewCell.matchTitleHeight/2 : 0)
        }

        watchCountButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-22)
            make.centerY.equalTo(teamMatchupView)
        }

        matchTitleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            if shouldShowMatchTitle {
                make.height.equalTo(MatchTableViewCell.matchTitleHeight)
            }
            else {
                make.height.equalTo(0)
            }
        }

        if match.isFullyWatched {
            watchCountButton.setTitle("\(match.watchCount)/\(match.data.count)", for: .normal)
            teamMatchupView.alpha = 0.4
            watchCountButton.alpha = 0.4
        }
        else {
            watchCountButton.setTitle("\(match.watchCount)/\(match.data.count)", for: .normal)
            watchCountButton.alpha = 1.0
        }

        if let title = match.title {
            self.matchTitleLabel.text = title
            self.matchTitleLabel.isHidden = false
        }
        else {
            self.matchTitleLabel.isHidden = true
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("IB not supported")
    }

}

