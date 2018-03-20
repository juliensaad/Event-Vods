//
//  HomeNavigationBar.swift
//  Eventvods
//
//  Created by Julien Saad on 2018-03-19.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit

protocol HomeHeaderViewDelegate: NSObjectProtocol {
    func headerViewDidTapRightArrow(_ headerView: HomeHeaderView)
    func headerViewDidTapLeftArrow(_ headerView: HomeHeaderView)
}

class HomeHeaderView: UIView {

    let slug: String

    lazy var logoView: UIButton = {
        let logoView = UIButton()
        logoView.setImage(UIImage(named: slug), for: .normal)
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

    lazy var rightArrow: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"right-1"), for: .normal)
        button.alpha = 0.6
        button.addTarget(self, action: #selector(tapArrowView(button:)), for: .touchUpInside)
        return button
    }()

    lazy var leftArrow: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"left-1"), for: .normal)
        button.alpha = 0.6
        button.addTarget(self, action: #selector(tapArrowView(button:)), for: .touchUpInside)
        return button
    }()

    weak var delegate: HomeHeaderViewDelegate?

    init(slug: String) {
        self.slug = slug
        super.init(frame: CGRect.zero)
        
        addSubview(logoView)
        addSubview(leftArrow)
        addSubview(rightArrow)
        
        logoView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(54)
        }

        rightArrow.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(10)
        }

        leftArrow.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(10)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    @objc private func tapArrowView(button: UIButton) {
        if button == leftArrow {
            delegate?.headerViewDidTapLeftArrow(self)
        }
        else {
            delegate?.headerViewDidTapRightArrow(self)
        }
    }

}