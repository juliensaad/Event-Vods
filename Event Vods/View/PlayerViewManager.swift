//
//  PlayerViewManager.swift
//  Event Vods
//
//  Created by Julien Saad on 2018-03-10.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import Foundation
import YoutubePlayer_in_WKWebView

class PlayerViewManager {
    static let shared = PlayerViewManager()

    let playerView: WKYTPlayerView
    init() {
        playerView = WKYTPlayerView()
        playerView.backgroundColor = UIColor.black
    }

    func prepare() {
        playerView.load(withPlayerParams: playerParams(seconds: 0))
        playerView.webView?.isUserInteractionEnabled = false
        playerView.isUserInteractionEnabled = false
    }

    func playerParams(seconds: TimeInterval) -> [String: Int] {
        return [
            "enablejsapi": 1,
            "rel": 0,
            "playsinline": 1,
            "autoplay": 1,
            "controls": 0,
            "showinfo": 0,
            "modestbranding": 1,
            "disablekb": 1,
            "iv_load_policy": 3,
            "start": Int(seconds)
            ]
    }
}
