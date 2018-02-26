//
//  PlaybackViewController.swift
//  Event Vods
//
//  Created by Julien Saad on 2018-02-17.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class PlaybackViewController: UIViewController, YTPlayerViewDelegate, UIGestureRecognizerDelegate {

    let url: String

    private lazy var minButton: UIButton = {
        let button = UIButton()
        button.setTitle("5 min", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.alpha = 0
        button.addTarget(self, action: #selector(tapMinButton), for: .touchUpInside)
        return button
    }()

    private lazy var youtubePlayer: YTPlayerView = {
        let playerView = YTPlayerView()
        playerView.webView?.allowsInlineMediaPlayback = true
        playerView.webView?.mediaPlaybackRequiresUserAction = false
        playerView.delegate = self

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapWebView))
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.delegate = self
        playerView.addGestureRecognizer(gestureRecognizer)
        playerView.webView?.isUserInteractionEnabled = false
        playerView.webView?.isUserInteractionEnabled = false
        return playerView
    }()

    var playbackURL: String {
        var embededURL = url.replacingOccurrences(of: "watch?v=", with: "embed/")

        var numberOfSeconds = 0
        if let query = getQueryStringParameter(url: url, param: "t") {
            numberOfSeconds = getNumberOfSeconds(string: query)
            embededURL = embededURL.replacingOccurrences(of: "&t=\(query)", with: "?start=\(numberOfSeconds)")
        }

        return "\(embededURL)&enablejsapi=1&rel=0&playsinline=1&autoplay=1&controls=0&showinfo=0&modestbranding=1"
    }

    init(url: String) {
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
        UIView.animate(withDuration: 0.3) {
            self.minButton.alpha = 1
        }
    }

    @objc func tapMinButton() {
        pauseVideo()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        view.addSubview(youtubePlayer)
        view.addSubview(minButton)

        youtubePlayer.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaInsets.top)
            make.bottom.equalTo(view.safeAreaInsets.bottom)
            make.left.equalTo(view.safeAreaInsets.left)
            make.right.equalTo(view.safeAreaInsets.right)
        }

        minButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view).offset(-10)
            make.centerX.equalTo(view)
        }

        loadVideo()
    }

    func loadVideo() {

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

    func playerViewPreferredWebViewBackgroundColor(_ playerView: YTPlayerView) -> UIColor {
        return UIColor.black
    }

    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        playerView.playVideo()
    }

    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        print(state)
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


}
