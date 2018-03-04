//
//  VideoPlayerOverlay.swift
//  Event Vods
//
//  Created by Julien Saad on 2018-02-25.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol VideoPlayerOverlayDelegate: NSObjectProtocol {
    func didTapOverlay(_ overlay: VideoPlayerOverlay)
    func didDoubleTapOverlay(_ overlay: VideoPlayerOverlay)
    func didTapPlay(_ overlay: VideoPlayerOverlay)
    func didTapPause(_ overlay: VideoPlayerOverlay)
    func didTapSeek(_ overlay: VideoPlayerOverlay, interval: TimeInterval)
    func didTapClose(_ overlay: VideoPlayerOverlay)
}

class VideoPlayerOverlay: UIView {

    private var spinner: SVIndefiniteAnimatedView = {
        let view = SVIndefiniteAnimatedView.init(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        view.strokeColor = UIColor.white
        view.radius = 12
        view.strokeThickness = 4
        return view
    }()

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
        let view = TeamMatchupView()
        view.isHidden = true
        return view
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
        button.titleLabel?.font = UIFont(name: "Avenir-Black", size: 30)
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        button.tintColor = .white
        button.clipsToBounds = true
        return button
    }()

    private lazy var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapOverlay))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        return doubleTapGestureRecognizer
    }()

    private lazy var container: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()

    private var seekButtons: [UIButton] = []

    override func layoutSubviews() {
        super.layoutSubviews()
        updateSeekButtonVisibility()
    }

    override func updateConstraints() {
        super.updateConstraints()
        updateSeekButtonVisibility()
    }

    func updateSeekButtonVisibility () {
        for button in seekButtons {
            if button.frame.origin.x < bounds.origin.x {
                button.alpha = 0
            }
            else if button.frame.maxX > bounds.maxX {
                button.alpha = 0
            }
            else {
                button.alpha = 1
            }
        }
    }

    init(match: Match) {
        self.match = match
        super.init(frame: CGRect.zero)

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOverlay))
        addGestureRecognizer(gestureRecognizer)
//        addGestureRecognizer(doubleTapGestureRecognizer)
//        container.addGestureRecognizer(gestureRecognizer)
//        container.addGestureRecognizer(doubleTapGestureRecognizer)
//        gestureRecognizer.require(toFail: doubleTapGestureRecognizer)

        matchupView.match = self.match

        addSubview(container)
        addSubview(spinner)
        container.backgroundColor = UIColor(white: 0, alpha: 0.45)
        container.addSubview(matchupView)
        container.addSubview(pauseButton)
        container.addSubview(playButton)
        container.addSubview(closeButton)

        let b0 = makeButton(direction: .left, seekTime: .fiveMin)
        let b1 = makeButton(direction: .left, seekTime: .oneMin)
        let b2 = makeButton(direction: .left, seekTime: .thirtySec)
        let b3 = makeButton(direction: .right, seekTime: .thirtySec)
        let b4 = makeButton(direction: .right, seekTime: .oneMin)
        let b5 = makeButton(direction: .right, seekTime: .fiveMin)

        seekButtons = [b0,b1,b2,b3,b4,b5]

        var referenceConstraintItem = playButton.snp.left
        for button in [b2,b1,b0] {
            container.addSubview(button)
            button.snp.makeConstraints({ (make) in
                make.right.equalTo(referenceConstraintItem).offset(-32)
                make.centerY.equalTo(playButton)
            })
            referenceConstraintItem = button.snp.left
            button.centerVertically()
        }

        referenceConstraintItem = playButton.snp.right
        for button in [b3,b4,b5] {
            container.addSubview(button)
            button.snp.makeConstraints({ (make) in
                make.left.equalTo(referenceConstraintItem).offset(32)
                make.centerY.equalTo(playButton)
            })
            referenceConstraintItem = button.snp.right
            button.centerVertically()
        }

        matchupView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.safeAreaLayoutGuide.snp.topMargin).inset(30)
            make.centerX.equalToSuperview()
        }

        playButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(6)
            make.size.equalTo(CGSize(width: VideoPlayerOverlay.playPauseButtonSize,
                                     height: VideoPlayerOverlay.playPauseButtonSize))
        }

        spinner.snp.makeConstraints { (make) in
            make.center.equalTo(pauseButton)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }

        pauseButton.snp.makeConstraints { (make) in
            make.edges.equalTo(playButton)
        }

        closeButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.topMargin).inset(10)
            make.right.equalTo(self.safeAreaLayoutGuide.snp.rightMargin).inset(14)
        }

        container.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
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

    @objc func doubleTapOverlay() {
        delegate?.didDoubleTapOverlay(self)
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

    func beginLoading() {
        spinner.alpha = 1
        playButton.imageView?.alpha = 0
        pauseButton.imageView?.alpha = 0
    }

    func stopLoading() {
        fadeOut()
        UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: [], animations: {
            self.spinner.alpha = 0
            self.playButton.imageView?.alpha = 1
            self.pauseButton.imageView?.alpha = 1
        }, completion: nil)
    }

    func fadeIn() {
        updateSeekButtonVisibility()
        UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: [], animations: {
            self.container.alpha = 1
        }, completion: nil)
        resetFadeTimer()
    }

    func fadeOut() {
        updateSeekButtonVisibility()
        UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: [], animations: {
            self.container.alpha = 0
        }, completion: nil)
    }
}
