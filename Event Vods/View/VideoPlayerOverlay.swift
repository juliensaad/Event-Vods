//
//  VideoPlayerOverlay.swift
//  Event Vods
//
//  Created by Julien Saad on 2018-02-25.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit

protocol VideoPlayerOverlayDelegate: NSObjectProtocol {
    func didTapOverlay(_ overlay: VideoPlayerOverlay)
    func didTapPlay(_ overlay: VideoPlayerOverlay)
    func didTapPause(_ overlay: VideoPlayerOverlay)
    func didTapSeek(_ overlay: VideoPlayerOverlay, interval: TimeInterval)
    func didTapClose(_ overlay: VideoPlayerOverlay)
}

class VideoPlayerOverlay: UIView {

    enum Direction: String {
        case right
        case left

        var multiplier: Int {
            switch self {
            case .right:
                return 1
            case .left:
                return -1
            }
        }
    }

    enum SeekTime: TimeInterval {
        case thirtySec = 30
        case oneMin = 60
        case fiveMin = 300

        var stringValue: String {
            switch self {
            case .thirtySec:
                return "30S"
            case .oneMin:
                return "1M"
            case .fiveMin:
                return "5M"
            }
        }

        var index: Int {
            switch self {
            case .thirtySec:
                return 1
            case .oneMin:
                return 2
            case .fiveMin:
                return 3
            }
        }
    }

    static let playPauseButtonSize: CGFloat = 60

    weak var delegate: VideoPlayerOverlayDelegate?
    let match: Match
    var fadeTimer: Timer?
    var isLandscape: Bool = false

    private lazy var matchupView: TeamMatchupView = {
        return TeamMatchupView()
    }()
    
    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"play")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0)
        button.addTarget(self, action: #selector(play), for: .touchUpInside)
        button.tintColor = .white
        button.layer.cornerRadius = VideoPlayerOverlay.playPauseButtonSize/2
        button.backgroundColor = UIColor(white: 0, alpha: 0.7)
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.controlGreen.cgColor
        button.clipsToBounds = true
        button.isHidden = true
        return button
    }()

    private lazy var pauseButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"pause")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(pause), for: .touchUpInside)
        button.tintColor = .white
        button.backgroundColor = UIColor(white: 0, alpha: 0.7)
        button.layer.cornerRadius = VideoPlayerOverlay.playPauseButtonSize/2
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.controlGreen.cgColor
        button.clipsToBounds = true
        return button
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("close", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir-Black", size: 16)
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        button.tintColor = .white
        button.clipsToBounds = true
        return button
    }()

    

    init(match: Match) {
        self.match = match
        super.init(frame: CGRect.zero)

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOverlay))
        addGestureRecognizer(gestureRecognizer)

        if let team1Icon = match.team1?.icon {
            matchupView.firstTeamIcon = URL(string: team1Icon)
        }

        if let team2Icon = match.team2?.icon {
            matchupView.secondTeamIcon = URL(string: team2Icon)
        }

        backgroundColor = UIColor(white: 0, alpha: 0.45)
        addSubview(matchupView)
        addSubview(pauseButton)
        addSubview(playButton)
        addSubview(closeButton)

        let b0 = makeButton(direction: .left, seekTime: .fiveMin)
        let b1 = makeButton(direction: .left, seekTime: .oneMin)
        let b2 = makeButton(direction: .left, seekTime: .thirtySec)
        let b3 = makeButton(direction: .right, seekTime: .thirtySec)
        let b4 = makeButton(direction: .right, seekTime: .oneMin)
        let b5 = makeButton(direction: .right, seekTime: .fiveMin)

        var referenceConstraintItem = playButton.snp.left
        for button in [b2,b1,b0] {
            addSubview(button)
            button.snp.makeConstraints({ (make) in
                make.right.equalTo(referenceConstraintItem).offset(-32)
                make.centerY.equalTo(playButton)
            })
            referenceConstraintItem = button.snp.left
            button.centerVertically()
        }

        referenceConstraintItem = playButton.snp.right
        for button in [b3,b4,b5] {
            addSubview(button)
            button.snp.makeConstraints({ (make) in
                make.left.equalTo(referenceConstraintItem).offset(32)
                make.centerY.equalTo(playButton)
            })
            referenceConstraintItem = button.snp.right
            button.centerVertically()
        }

        matchupView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.safeAreaLayoutGuide).inset(50)
            make.centerX.equalToSuperview()
        }

        playButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(6)
            make.size.equalTo(CGSize(width: VideoPlayerOverlay.playPauseButtonSize,
                                     height: VideoPlayerOverlay.playPauseButtonSize))
        }

        pauseButton.snp.makeConstraints { (make) in
            make.edges.equalTo(playButton)
        }

        closeButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.topMargin).inset(20)
            make.right.equalTo(self.safeAreaLayoutGuide.snp.rightMargin).inset(30)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    @objc func pause() {
        delegate?.didTapPause(self)
        pauseButton.isHidden = true
        playButton.isHidden = false
        resetFadeTimer()
    }

    @objc func play() {
        delegate?.didTapPlay(self)
        pauseButton.isHidden = false
        playButton.isHidden = true
        resetFadeTimer()
    }

    @objc func tapOverlay() {
        if let timer = fadeTimer {
            if timer.isValid {
                fadeTimer!.invalidate()
                fadeTimer = nil
                fadeOut()
                return
            }
        }
        delegate?.didTapOverlay(self)
    }

    @objc func close() {
        delegate?.didTapClose(self)
        resetFadeTimer()
    }

    @objc func tapSeekButton(button: UIButton) {
        delegate?.didTapSeek(self, interval: TimeInterval(button.tag))
        resetFadeTimer()
    }

    func resetFadeTimer() {
        fadeTimer?.invalidate()
        fadeTimer = nil
        fadeTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (timer) in
            self.fadeOut()
        }
    }

    func makeButton(direction: Direction, seekTime: SeekTime) -> UIButton {
        let button = UIButton()
        let image = UIImage(named: "\(direction.rawValue)-\(seekTime.index)")
        button.setImage(image, for: .normal)
        button.setTitle(seekTime.stringValue, for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir-Black", size: 16)
        button.tag = Int(seekTime.rawValue) * direction.multiplier
        button.addTarget(self, action: #selector(tapSeekButton), for: .touchUpInside)
        return button
    }

    func fadeIn() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
        resetFadeTimer()
    }

    func fadeOut() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        }
    }
}

extension UIButton {

    func centerVertically(padding: CGFloat = 6.0) {
        guard
            let imageViewSize = self.imageView?.frame.size,
            let titleLabelSize = self.titleLabel?.frame.size else {
                return
        }

        let totalHeight = imageViewSize.height + titleLabelSize.height + padding

        self.imageEdgeInsets = UIEdgeInsets(
            top: -(totalHeight - imageViewSize.height),
            left: 0.0,
            bottom: 0.0,
            right: -titleLabelSize.width
        )

        self.titleEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: -imageViewSize.width,
            bottom: -(totalHeight - titleLabelSize.height),
            right: 0.0
        )

        self.contentEdgeInsets = UIEdgeInsets(
            top: titleLabelSize.height,
            left: 0.0,
            bottom: titleLabelSize.height,
            right: 0.0
        )
    }

}
