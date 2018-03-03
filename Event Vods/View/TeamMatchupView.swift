//
//  TeamMatchupView.swift
//  Event Vods
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
                if let team1Icon = match.team1.icon, let team2Icon = match.team2.icon {
                    firstTeamIcon = URL(string: team1Icon)
                    secondTeamIcon = URL(string: team2Icon)
                }
                else {
                    // setup labels
                }
            }
        }
    }

    private lazy var firstTeamImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0.2
        imageView.layer.shadowRadius = 6
        imageView.layer.shadowOffset = CGSize(width: 0, height: 1)
        return imageView
    }()

    private lazy var secondTeamImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0.2
        imageView.layer.shadowRadius = 6
        imageView.layer.shadowOffset = CGSize(width: 0, height: 1)
        return imageView
    }()

    private lazy var vsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "Avenir-Black", size: 24)
        label.text = NSLocalizedString("vs", comment: "")
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 0.2
        label.layer.shadowRadius = 6
        label.layer.shadowOffset = CGSize(width: 0, height: 1)
        return label
    }()

    var firstTeamResource: Resource? {
        willSet {
            firstTeamResource?.removeObservers(ownedBy: self)
            firstTeamResource?.cancelLoadIfUnobserved(afterDelay: 0.05)
        }

        didSet {
            firstTeamResource?.loadIfNeeded()
            firstTeamResource?.addObserver(owner: self) { [weak self] _,_ in
                self?.firstTeamImageView.image = self?.firstTeamResource?.typedContent(
                    ifNone: self?.placeholderImage)
            }
        }
    }

    var secondTeamResource: Resource? {
        willSet {
            secondTeamResource?.removeObservers(ownedBy: self)
            secondTeamResource?.cancelLoadIfUnobserved(afterDelay: 0.05)
        }

        didSet {
            secondTeamResource?.loadIfNeeded()
            secondTeamResource?.addObserver(owner: self) { [weak self] _,_ in
                self?.secondTeamImageView.image = self?.secondTeamResource?.typedContent(
                    ifNone: self?.placeholderImage)
            }
        }
    }

    var firstTeamIcon: URL? {
        get { return firstTeamResource?.url }
        set { firstTeamResource = ImageCache.resource(absoluteURL: newValue) }
    }

    var secondTeamIcon: URL? {
        get { return secondTeamResource?.url }
        set { secondTeamResource = ImageCache.resource(absoluteURL: newValue) }
    }

    var placeholderImage: UIImage {
        return UIImage()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)

        addSubview(firstTeamImageView)
        addSubview(secondTeamImageView)
        addSubview(vsLabel)

        firstTeamImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().offset(-80)
            make.height.equalToSuperview()
        }
    
        secondTeamImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().offset(80)
            make.height.equalToSuperview()
        }

        vsLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 50)
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

}