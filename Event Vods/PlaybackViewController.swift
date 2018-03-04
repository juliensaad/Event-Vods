//
//  PlaybackViewController.swift
//  Event Vods
//
//  Created by Julien Saad on 2018-02-17.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit
import YoutubePlayer_in_WKWebView
import SVProgressHUD

class PlaybackViewController: UIViewController, UIGestureRecognizerDelegate {

    let match: Match
    let url: String?
    var hasPlayedVideo: Bool = false

    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)

    private lazy var overlay: VideoPlayerOverlay = {
        let overlay = VideoPlayerOverlay(match: match)
        overlay.delegate = self
        return overlay
    }()

    private lazy var youtubePlayer: WKYTPlayerView = {
        let playerView = WKYTPlayerView()
        playerView.delegate = self
        playerView.alpha = 0.01
        playerView.backgroundColor = UIColor.black
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapWebView))
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.delegate = self
        playerView.addGestureRecognizer(gestureRecognizer)
        return playerView
    }()

    init(match: Match, url: String?) {
        self.match = match
        self.url = url
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
        youtubePlayer.setNeedsLayout()
        setupWebView()
        super.updateViewConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsUpdateOfHomeIndicatorAutoHidden()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }

    func setupWebView() {
        youtubePlayer.webView?.isUserInteractionEnabled = false
//        youtubePlayer.webView?.allowsInlineMediaPlayback = true
//        youtubePlayer.webView?.mediaPlaybackRequiresUserAction = false
        youtubePlayer.webView?.scrollView.contentInsetAdjustmentBehavior = .never
    }

    func loadVideo() {
        overlay.beginLoading()
        setupWebView()

        guard let url = self.url else {
            return
        }

        var numberOfSeconds = 0

        if let query = getQueryStringParameter(url: url, param: "t") {
            numberOfSeconds = query.getNumberOfSeconds()
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

        if let videoID = getQueryStringParameter(url: url, param: "v") {
            youtubePlayer.load(withVideoId: videoID, playerVars: playerVars)
        }
        else {
            youtubePlayer.loadVideo(byURL: url, startSeconds: 0, suggestedQuality: WKYTPlaybackQuality.auto)
        }
    }

    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }

    @objc func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
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

}

// MARK : YTPlayerViewDelegate
extension PlaybackViewController: WKYTPlayerViewDelegate {

    func playerViewPreferredWebViewBackgroundColor(_ playerView: WKYTPlayerView) -> UIColor {
        return UIColor.black
    }

    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
        playerView.playVideo()
    }

    func playerView(_ playerView: WKYTPlayerView, didChangeTo state: WKYTPlayerState) {
        if state != .buffering && state != .unstarted {
            playerView.alpha = 1

            if state != .paused || !hasPlayedVideo {
                youtubePlayer.playVideo()
            }
            overlay.fadeOut()
            overlay.stopLoading()
        }
        else {
            playerView.alpha = 0.01
        }
    }

    func playerView(_ playerView: WKYTPlayerView, didPlayTime playTime: Float) {
        hasPlayedVideo = true
        playerView.alpha = 1
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

        youtubePlayer.getCurrentTime { (time, error) in
            self.youtubePlayer.seek(toSeconds: time + Float(interval), allowSeekAhead: true)
        }

    }

    func didDoubleTapOverlay(_ overlay: VideoPlayerOverlay) {
        //youtubePlayer.seek(toSeconds: youtubePlayer.currentTime() + Float(10), allowSeekAhead: true)
    }

    func didTapClose(_ overlay: VideoPlayerOverlay) {
        dismiss(animated: true, completion: nil)
    }
}
