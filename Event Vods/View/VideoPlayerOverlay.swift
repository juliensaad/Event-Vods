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

    static let playPauseButtonSize: CGFloat = 60

    weak var delegate: VideoPlayerOverlayDelegate?
    let match: Match
    var fadeTimer: Timer?

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
        button.titleLabel?.font = UIFont(name: "Avenir-Bold", size: 30)
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

        backgroundColor = UIColor(white: 0, alpha: 0.35)
        addSubview(matchupView)
        addSubview(pauseButton)
        addSubview(playButton)
        addSubview(closeButton)

        matchupView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.safeAreaLayoutGuide).inset(50)
            make.centerX.equalToSuperview()
        }

        playButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: VideoPlayerOverlay.playPauseButtonSize,
                                     height: VideoPlayerOverlay.playPauseButtonSize))
        }

        pauseButton.snp.makeConstraints { (make) in
            make.edges.equalTo(playButton)
        }

        closeButton.snp.makeConstraints { (make) in
            make.top.right.equalTo(self.safeAreaLayoutGuide).inset(20)
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
        delegate?.didTapOverlay(self)
    }

    @objc func close() {
        delegate?.didTapClose(self)
        resetFadeTimer()
    }

    func resetFadeTimer() {
        fadeTimer?.invalidate()
        fadeTimer = nil
        fadeTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (timer) in
            self.fadeOut()
        }
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
