//
//  DetailsHeaderView.swift
//  Eventvods
//
//  Created by Julien Saad on 2018-03-19.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit

class DetailsHeaderView: UIView {

    let event: Event

    lazy var logoView: UIButton = {
        let logoView = UIButton()
        if let logo = event.logo, let url = URL(string:logo) {
            logoView.kf.setImage(with: url, for: .normal)
        }
        else {
            logoView.setTitle(event.name, for: .normal)
        }

        logoView.imageView?.contentMode = .scaleAspectFit
        logoView.imageEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4)
        logoView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        logoView.layer.shadowColor = UIColor.black.cgColor
        logoView.layer.shadowOpacity = 0.2
        logoView.layer.shadowRadius = 6
        logoView.layer.shadowOffset = CGSize(width: 0, height: 1)
        logoView.isUserInteractionEnabled = false
        logoView.layer.shouldRasterize = true
        logoView.layer.rasterizationScale = UIScreen.main.scale
        return logoView
    }()

    lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"back")?.withRenderingMode(.alwaysTemplate),
                        for: .normal)
        button.tintColor = .white
        button.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        return button
    }()

    init(event: Event) {
        self.event = event
        super.init(frame: CGRect.zero)

        addSubview(logoView)
        addSubview(backButton)

        logoView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(54)
        }

        backButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview()
            make.height.equalTo(24)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

}

