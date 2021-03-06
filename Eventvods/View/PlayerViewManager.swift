//
//  PlayerViewManager.swift
//  Eventvods
//
//  Created by Julien Saad on 2018-03-10.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import Foundation
import youtube_ios_player_helper

class PlayerViewManager {
    static let shared = PlayerViewManager()

    let playerView: YTPlayerView

    init() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            playerView = YTPlayerView(frame: CGRect(x: 0, y: 0, width: 4096, height: 2360))
            playerView.translatesAutoresizingMaskIntoConstraints = false
        }
        else {
            playerView = YTPlayerView()
        }

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
