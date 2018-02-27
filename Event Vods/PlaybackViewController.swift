//
//  PlaybackViewController.swift
//  Event Vods
//
//  Created by Julien Saad on 2018-02-17.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class PlaybackViewController: UIViewController, UIGestureRecognizerDelegate {

    let match: Match
    var hasPlayedVideo: Bool = false

    private lazy var overlay: VideoPlayerOverlay = {
        let overlay = VideoPlayerOverlay(match: match)
        overlay.delegate = self
        overlay.alpha = 0
        return overlay
    }()

    private lazy var youtubePlayer: YTPlayerView = {
        let playerView = YTPlayerView()
        playerView.delegate = self
        playerView.alpha = 0.01
        playerView.backgroundColor = UIColor.black
        playerView.delegate = self
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapWebView))
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.delegate = self
        playerView.addGestureRecognizer(gestureRecognizer)
        return playerView
    }()

    init(match: Match) {
        self.match = match
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

    override func updateViewConstraints() {
        youtubePlayer.snp.remakeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.left.equalTo(view.safeAreaLayoutGuide.snp.leftMargin)
            if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
                make.bottom.equalTo(view.snp.bottom)
            }
            else {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin)
            }
            make.right.equalTo(view.safeAreaLayoutGuide.snp.rightMargin)
        }
        setupWebView()
        super.updateViewConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsUpdateOfHomeIndicatorAutoHidden()
    }

    func setupWebView() {
        youtubePlayer.webView?.isUserInteractionEnabled = false
        youtubePlayer.webView?.allowsInlineMediaPlayback = true
        youtubePlayer.webView?.mediaPlaybackRequiresUserAction = false
        youtubePlayer.webView?.scrollView.contentInsetAdjustmentBehavior = .never
    }

    func loadVideo() {
        setupWebView()

        guard let url = match.data?.first?.youtube.gameStart else {
            // handle bad URL error
            return
        }

        var numberOfSeconds = 0

        if let query = getQueryStringParameter(url: url, param: "t") {
            numberOfSeconds = getNumberOfSeconds(string: query)
        }

        let playerVars = [
            "enablejsapi": 1,
            "rel": 0,
            "playsinline": 1,
            "autoplay": 1,
            "controls": 0,
            "showinfo": 0,
            "modestbranding": 1,
            "disablekb": 1,
            "start": numberOfSeconds
            ]

        // todo: Safety
        let videoID = getQueryStringParameter(url: url, param: "v")
        youtubePlayer.load(withVideoId: videoID!, playerVars: playerVars)
    }

    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }

    func getNumberOfSeconds(string: String) -> Int {
        var timeString = string

        var total = 0
        if timeString.contains("h") {
            let hours = timeString.components(separatedBy: "h").first
            if let hours = hours {
                timeString = timeString.replacingOccurrences(of: "\(hours)h", with: "")
                total += Int(hours)! * 3600
            }
        }

        if timeString.contains("m") {
            let minutes = timeString.components(separatedBy: "m").first
            if let minutes = minutes {
                timeString = timeString.replacingOccurrences(of: "\(minutes)m", with: "")
                total += Int(minutes)! * 60
            }
        }

        if timeString.contains("s") {
            let seconds = timeString.components(separatedBy: "s").first
            if let seconds = seconds {
                timeString = timeString.replacingOccurrences(of: "\(seconds)s", with: "")
                total += Int(seconds)!
            }
        }


        return total
    }

    func pauseVideo() {
        self.youtubePlayer.pauseVideo()
    }

    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
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
        if state != .buffering && state != .unstarted {
            playerView.alpha = 1
        }
        else {
            playerView.alpha = 0.01
        }
    }

    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
        hasPlayedVideo = true
        playerView.alpha = 1
        print("Did play time \(playTime)")
    }
}

extension PlaybackViewController: VideoPlayerOverlayDelegate {
    func didTapOverlay(_ overlay: VideoPlayerOverlay) {
        if !hasPlayedVideo {
            youtubePlayer.playVideo()
            hasPlayedVideo = true
        }
        overlay.fadeIn()
    }

    func didTapPlay(_ overlay: VideoPlayerOverlay) {
        youtubePlayer.playVideo()
    }

    func didTapPause(_ overlay: VideoPlayerOverlay) {
        youtubePlayer.pauseVideo()
    }

    func didTapSeek(_ overlay: VideoPlayerOverlay, interval: TimeInterval) {

    }

    func didTapClose(_ overlay: VideoPlayerOverlay) {
        dismiss(animated: true, completion: nil)
    }
}
