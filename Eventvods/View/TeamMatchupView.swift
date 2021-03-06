//
//  TeamMatchupView.swift
//  Eventvods
//
//  Created by Julien Saad on 2018-02-25.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit
import Siesta

class TeamMatchupView: UIView {

    var match: Match? {
        didSet {
            if let match = match {
                if match.spoiler1 {
                    let placeholder = UIImage(named: match.gameSlug)
                    firstTeamImageView.image = placeholder
                }
                else if let team1Icon = match.team1.icon {
                    firstTeamImageView.kf.indicatorType = .activity
                    firstTeamImageView.kf.setImage(with: URL(string: team1Icon), placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, _, _, _) in
                        if image == nil {
                            self.failedFirstImage = true
                        }
                        self.setNeedsUpdateConstraints()
                    })
                }

                if match.spoiler2 {
                    let placeholder = UIImage(named: match.gameSlug)
                    secondTeamImageView.image = placeholder
                }
                else if let team2Icon = match.team2.icon {
                    secondTeamImageView.kf.indicatorType = .activity
                    secondTeamImageView.kf.setImage(with: URL(string: team2Icon), placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, _, _, _) in
                        if image == nil {
                            self.failedSecondImage = true
                        }
                        self.setNeedsUpdateConstraints()
                    })
                }

                firstTeamLabel.text = match.team1Title
                secondTeamLabel.text = match.team2Title
            }
        }
    }

    var failedFirstImage = false
    var failedSecondImage = false

    private lazy var firstTeamImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0.2
        imageView.layer.shadowRadius = 6
        imageView.layer.shadowOffset = CGSize(width: 0, height: 1)
        imageView.layer.shouldRasterize = true
        imageView.layer.rasterizationScale = UIScreen.main.scale
        return imageView
    }()

    private lazy var secondTeamImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0.2
        imageView.layer.shadowRadius = 6
        imageView.layer.shadowOffset = CGSize(width: 0, height: 1)
        imageView.layer.shouldRasterize = true
        imageView.layer.rasterizationScale = UIScreen.main.scale
        return imageView
    }()

    private lazy var firstTeamLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldVodsFontOfSize( 16)
        label.textColor = UIColor.white
        label.layer.shadowOffset = CGSize(width: 0, height: 1)
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 0.2
        label.layer.shadowRadius = 6
        label.layer.shouldRasterize = true
        label.layer.rasterizationScale = UIScreen.main.scale
        return label
    }()

    private lazy var secondTeamLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldVodsFontOfSize( 16)
        label.textColor = UIColor.white
        label.layer.shadowOffset = CGSize(width: 0, height: 1)
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 0.2
        label.layer.shadowRadius = 6
        label.layer.shouldRasterize = true
        label.layer.rasterizationScale = UIScreen.main.scale
        return label
    }()

    lazy var vsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldVodsFontOfSize( 24)
        label.text = NSLocalizedString("vs", comment: "")
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 0.2
        label.layer.shadowRadius = 6
        label.layer.shadowOffset = CGSize(width: 0, height: 1)
        label.layer.shouldRasterize = true
        label.layer.rasterizationScale = UIScreen.main.scale
        return label
    }()

    var placeholderImage: UIImage {
        return UIImage()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)

        addSubview(firstTeamImageView)
        addSubview(secondTeamImageView)
        addSubview(firstTeamLabel)
        addSubview(secondTeamLabel)
        addSubview(secondTeamImageView)
        addSubview(vsLabel)

        firstTeamImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-14)
            make.centerX.equalToSuperview().offset(-80)
            make.height.equalTo(44)
        }
    
        secondTeamImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-14)
            make.centerX.equalToSuperview().offset(80)
            make.height.equalTo(44)
        }

        firstTeamLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(firstTeamImageView)
            make.top.equalTo(firstTeamImageView.snp.bottom).offset(8)
        }

        secondTeamLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(secondTeamImageView)
            make.top.equalTo(firstTeamImageView.snp.bottom).offset(8)
        }

        vsLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }

    override func updateConstraints() {
        super.updateConstraints()

        if failedFirstImage {
            firstTeamLabel.snp.remakeConstraints { (make) in
                make.centerX.equalTo(firstTeamImageView)
                make.centerY.equalToSuperview()
            }
        }

        if failedSecondImage {
            secondTeamLabel.snp.remakeConstraints { (make) in
                make.centerX.equalTo(secondTeamImageView)
                make.centerY.equalToSuperview()
            }
        }

    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 50)
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

}
