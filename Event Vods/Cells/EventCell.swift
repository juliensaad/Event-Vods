//
//  EventCell.swift
//  Event Vods
//
//  Created by Julien Saad on 2018-02-11.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import SnapKit
import Siesta
import Kingfisher

class EventCell: UITableViewCell {
    
    static let reuseIdentifier = "EventCell"
    
    private lazy var eventImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.kf.indicatorType = .activity
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        return imageView
    }()
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.alpha = 0.5
        imageView.image = UIImage(named: "16")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var placeholderImage: UIImage {
        return UIImage()
    }
    
    private lazy var eventNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldVodsFontOfSize( 30)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldVodsFontOfSize( 16)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.lightVodsFontOfSize( 14)
        label.textColor = .white
        label.text = "Jan 20 2018 - Mar 18, 2018"
        label.numberOfLines = 0
        return label
    }()

    lazy var overlay: UIView = {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = UIColor.black
        return view
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
    
    init(event: Event, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        eventNameLabel.text = event.name
        subtitleLabel.text = event.subtitle
        backgroundImageView.image = UIImage(named: event.backgroundImageName)
        backgroundImageView.clipsToBounds = true
        dateLabel.text = event.dateRangeText
        contentView.clipsToBounds = true
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(eventNameLabel)
        contentView.addSubview(eventImageView)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(overlay)
        contentView.backgroundColor = .black

        let verticalMargin = 15

        eventImageView.snp.makeConstraints { (make) in
            make.right.equalTo(contentView).offset(-14)
            make.top.equalTo(contentView).offset(verticalMargin)
            make.height.width.equalTo(80)
        }
        
        backgroundImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView)
        }
        
        eventNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(verticalMargin)
            make.left.equalTo(contentView).offset(20)
            make.right.equalTo(eventImageView.snp.left).offset(-20)
        }

        subtitleLabel.snp.makeConstraints { (make) in
            make.top.greaterThanOrEqualTo(eventNameLabel.snp.bottom).offset(20)
            make.bottom.equalTo(dateLabel.snp.top).offset(-5)
            make.left.equalTo(eventNameLabel)
        }

        dateLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(contentView).offset(-verticalMargin)
            make.left.equalTo(eventNameLabel)
        }

        if let logo = event.logo, let url = URL(string:logo) {
            eventImageView.kf.setImage(with: url)
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
