//
//  MatchData.swift
//  Eventvods
//
//  Created by Julien Saad on 2018-02-17.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit

class MatchData: Decodable {
    let _id: String
    let rating: Float?
    let youtube: YoutubeLink?
    let twitch: TwitchLink?
    let placeholder: Bool?

    let links: [String?]

    var isComingSoon: Bool {
        return gameStart == nil
    }

    var gameStart: String? {
        if let youtube = youtube {
            return youtube.gameStart
        }
        else if let twitch = twitch {
            return twitch.gameStart
        }
        return nil
    }

    var watched: Bool {
        if UserDataManager.shared.getProgressionForMatch(match: self) != nil {
            return true
        }
        return UserDataManager.shared.getHighlightsWatchedForMatch(match: self)
    }
}
