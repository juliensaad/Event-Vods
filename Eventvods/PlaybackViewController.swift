//
//  PlaybackViewController.swift
//  Eventvods
//
//  Created by Julien Saad on 2018-02-17.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit
import youtube_ios_player_helper
import SVProgressHUD
import ABVolumeControl
import XCDYouTubeKit

class PlaybackViewController: UIViewController, UIGestureRecognizerDelegate {

    let match: Match
    let matchData: MatchData
    let url: String?
    let time: TimeInterval?
    var hasPlayedVideo: Bool = false
    var setQuality: Bool = false

    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)

    private lazy var overlay: VideoPlayerOverlay = {
        let overlay = VideoPlayerOverlay(match: match)
        overlay.delegate = self
        return overlay
    }()

    let highlights: Bool
    let youtubePlayer: YTPlayerView = PlayerViewManager.shared.playerView

    var player: XCDYouTubeVideoPlayerViewController!
    var saveTimeTimer: Timer?

    init(match: Match, matchData: MatchData, url: String?, time: TimeInterval?, highlights: Bool) {
        self.match = match
        self.matchData = matchData
        self.url = url
        self.time = time
        self.highlights = highlights
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    @objc func didTapWebView() {
        overlay.tapOverlay()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerHandler)))
        view.backgroundColor = UIColor.black
        view.addSubview(youtubePlayer)
        view.addSubview(overlay)
        overlay.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        loadVideo()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        view.setNeedsUpdateConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsUpdateOfHomeIndicatorAutoHidden()
        (ABVolumeControl.sharedManager() as! ABVolumeControl).volumeControlStyle = ABVolumeControlStyle.minimal
        (ABVolumeControl.sharedManager() as! ABVolumeControl).defaultDarkColor = UIColor.black

        saveTimeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
            self.savePlaybackTime()
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if UIDevice.current.userInterfaceIdiom == .phone {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
        player.moviePlayer.stop()
        saveTimeTimer?.invalidate()
        saveTimeTimer = nil
        (ABVolumeControl.sharedManager() as! ABVolumeControl).volumeControlStyle = ABVolumeControlStyle.minimal
    }

    func loadVideo() {
//        overlay.beginLoading()
//        setupWebView()

        guard let url = self.url else {
            return
        }

        var numberOfSeconds: TimeInterval = 0

        if let time = time {
            numberOfSeconds = time
        }
        else if let query = url.getQueryStringParameter("t") {
            numberOfSeconds = query.getNumberOfSeconds()
        }

        if let videoID = url.getQueryStringParameter("v") {
//            youtubePlayer.load(withVideoId: videoID, playerVars: PlayerViewManager.shared.playerParams(seconds: numberOfSeconds))
            player = XCDYouTubeVideoPlayerViewController(videoIdentifier: videoID)
            player.moviePlayer.initialPlaybackTime = numberOfSeconds
            player.present(in: self.view)
            player.moviePlayer.play()

            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapWebView))
            gestureRecognizer.numberOfTapsRequired = 1
            gestureRecognizer.delegate = self
            player.moviePlayer.view.addGestureRecognizer(gestureRecognizer)
            self.view.bringSubview(toFront: overlay)
        }
        else {
            youtubePlayer.loadVideo(byURL: url, startSeconds: 0, suggestedQuality: YTPlaybackQuality.HD720)
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }

    @objc func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        if (UIDevice.current.userInterfaceIdiom == .phone && UIDeviceOrientationIsLandscape(UIDevice.current.orientation)) || UIDevice.current.userInterfaceIdiom == .pad {
            return
        }

        let touchPoint = sender.location(in: self.view.window)

        if sender.state == UIGestureRecognizerState.began {
            initialTouchPoint = touchPoint
        }
        else if sender.state == UIGestureRecognizerState.changed {
            self.view.frame = CGRect(x: 0, y: touchPoint.y - initialTouchPoint.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
        }
        else if sender.state == UIGestureRecognizerState.ended || sender.state == UIGestureRecognizerState.cancelled {
            if touchPoint.y - initialTouchPoint.y > 100 || initialTouchPoint.y - touchPoint.y > 100 {
                self.dismiss(animated: true, completion: nil)
            }
            else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                })
            }
        }
    }

    func savePlaybackTime() {
        if !self.highlights {
            if player != nil && player.moviePlayer != nil {
                let playTime = player.moviePlayer.currentPlaybackTime
                if !playTime.isNaN {
                    UserDataManager.shared.saveVideoProgression(forMatch: self.matchData, time: playTime)
                }
            }
        }
        else {
            UserDataManager.shared.saveHighlightsWatched(forMatch: self.matchData)
        }
    }

}

// MARK : YTPlayerViewDelegate
extension PlaybackViewController: YTPlayerViewDelegate {

    func playerViewPreferredWebViewBackgroundColor(_ playerView: YTPlayerView) -> UIColor {
        return UIColor.black
    }

    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        playerView.playVideo()
    }

    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        if state == .ended {
            dismiss(animated: true, completion: nil)
        }
        
        if state != .buffering && state != .unstarted {
            playerView.alpha = 1

            if state != .paused || !hasPlayedVideo {
                youtubePlayer.playVideo()
            }
            overlay.stopLoading()
        }
        else {
            playerView.alpha = 0.01
        }
    }

    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
        hasPlayedVideo = true
        playerView.alpha = 1

        savePlaybackTime()
    }

}

extension PlaybackViewController: VideoPlayerOverlayDelegate {
    func didTapOverlay(_ overlay: VideoPlayerOverlay) {
        overlay.fadeIn()
    }

    func didTapPlay(_ overlay: VideoPlayerOverlay) {
        player.moviePlayer.play()
    }

    func didTapPause(_ overlay: VideoPlayerOverlay) {
        player.moviePlayer.pause()
    }

    func didTapSeek(_ overlay: VideoPlayerOverlay, interval: TimeInterval) {
        player.moviePlayer.currentPlaybackTime = player.moviePlayer.currentPlaybackTime + interval
    }

    func didDoubleTapOverlay(_ overlay: VideoPlayerOverlay, location: Location) {
        switch location {
        case .right:
            player.moviePlayer.currentPlaybackTime = player.moviePlayer.currentPlaybackTime + 15
        case .left:
            player.moviePlayer.currentPlaybackTime = player.moviePlayer.currentPlaybackTime - 15
        }
    }

    func didTapClose(_ overlay: VideoPlayerOverlay) {
        dismiss(animated: true, completion: nil)
    }
}
