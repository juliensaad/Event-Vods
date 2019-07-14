//
//  HomeNavigationBar.swift
//  Eventvods
//
//  Created by Julien Saad on 2018-03-19.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit
import SnapKit

protocol HomeHeaderViewDelegate: NSObjectProtocol {
    func headerViewDidTapRightArrow(_ headerView: HomeHeaderView)
    func headerViewDidTapLeftArrow(_ headerView: HomeHeaderView)
    func headerViewTextDidChange(_ headerView: HomeHeaderView, text: String)
}

class HomeHeaderView: UIView, UISearchBarDelegate {

    let slug: String
    static let searchBarHeight: CGFloat = 40.0

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

    lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.backgroundColor = .clear
        bar.barTintColor = .white
        bar.placeholder = "Search"
        bar.isTranslucent = true
        bar.delegate = self
        bar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        bar.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: UILayoutConstraintAxis.vertical)
        return bar
    }()

    weak var delegate: HomeHeaderViewDelegate?
    var shouldBeginEditing = true
    var searchBarHeightConstraint: Constraint!

    init(slug: String) {
        self.slug = slug
        super.init(frame: CGRect.zero)
        
        addSubview(logoView)
        addSubview(leftArrow)
        addSubview(rightArrow)
        addSubview(searchBar)
        
        logoView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()

            if #available(iOS 11.0, *) {
                make.height.equalTo(54)
                make.top.equalToSuperview().offset(20)
            }
            else {
                make.height.equalTo(44)
                make.top.equalToSuperview().offset(30)
            }
        }

        searchBar.snp.makeConstraints { (make) in
            make.top.equalTo(logoView.snp.bottom).offset(14).priority(749)
            make.left.equalToSuperview().offset(24).priority(749)
            make.right.equalToSuperview().offset(-24).priority(749)
            make.bottom.equalToSuperview().offset(-10).priority(749)
            self.searchBarHeightConstraint = make.height.equalTo(0).priority(1000).constraint
        }

        rightArrow.snp.makeConstraints { (make) in
            make.centerY.equalTo(logoView)
            make.right.equalToSuperview()
            make.width.height.equalTo(50)
        }

        leftArrow.snp.makeConstraints { (make) in
            make.centerY.equalTo(logoView)
            make.left.equalToSuperview()
            make.width.height.equalTo(50)
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

    func setLogoHidden(_ hidden: Bool, animated: Bool) {
        if (animated) {
            UIView.animateKeyframes(withDuration: 0.1, delay: 0, options: [], animations: {
                self.logoView.alpha = hidden ? 0 : 1
            }, completion: nil)
        }
        else {
            self.logoView.alpha = hidden ? 0 : 1
        }
    }

    func reloadArrowViews(hidden: Bool, viewController: UIViewController) {
        if hidden {
            leftArrow.isHidden = true
            rightArrow.isHidden = true
        }
        else if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let currentIndex = appDelegate.pageController.index(of: viewController)
            let lastIndex = appDelegate.pageController.viewControllers.count - 1
            leftArrow.isHidden = false
            rightArrow.isHidden = false
            if currentIndex == 0 {
                leftArrow.isHidden = true
            }
            else if currentIndex == lastIndex {
                rightArrow.isHidden = true
            }
        }
    }

    @discardableResult override func resignFirstResponder() -> Bool {
        return searchBar.resignFirstResponder()
    }

    // MARK: Search bar

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        let boolToReturn = shouldBeginEditing
        shouldBeginEditing = true
        return boolToReturn
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchBar.isFirstResponder {
            shouldBeginEditing = false
        }
        delegate?.headerViewTextDidChange(self, text: searchText)
    }
}
