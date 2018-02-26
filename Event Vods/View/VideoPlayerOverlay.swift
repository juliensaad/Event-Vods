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
}

class VideoPlayerOverlay: UIView {

    static let playPauseButtonSize: CGFloat = 50

    weak var delegate: VideoPlayerOverlayDelegate?
    let match: Match
    var fadeTimer: Timer?

    private lazy var matchupView: TeamMatchupView = {
        return TeamMatchupView()
    }()
    
    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(play), for: .touchUpInside)
        button.tintColor = .white
        button.layer.cornerRadius = VideoPlayerOverlay.playPauseButtonSize/2
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.lolGreen.cgColor
        button.clipsToBounds = true
        button.isHidden = true
        return button
    }()

    private lazy var pauseButton: UIButton = {
        let button = UIButton()
//        button.setImage(UIImage(named:"pause")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.setTitle("||", for: .normal)
        button.addTarget(self, action: #selector(pause), for: .touchUpInside)
        button.tintColor = .white
        button.layer.cornerRadius = VideoPlayerOverlay.playPauseButtonSize/2
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.lolGreen.cgColor
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

        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {

        }
        
        addSubview(matchupView)
        addSubview(pauseButton)
        addSubview(playButton)

        matchupView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(60)
            make.centerX.equalToSuperview()
        }

        playButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(30)
            make.size.equalTo(CGSize(width: VideoPlayerOverlay.playPauseButtonSize,
                                     height: VideoPlayerOverlay.playPauseButtonSize))
        }

        pauseButton.snp.makeConstraints { (make) in
            make.edges.equalTo(playButton)
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
