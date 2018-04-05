//
//  UserDataManager.swift
//  Eventvods
//
//  Created by Julien Saad on 2018-03-09.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit

extension DefaultsKeys {
    static let watchProgression = DefaultsKey<[String : Any]>("watchProgression")
    static let highlights = DefaultsKey<[String : Any]>("highlights")
    static let gameIndex = DefaultsKey<Int>("gameIndex")
}

class UserDataManager: NSObject {
    static let shared = UserDataManager()

    func saveVideoProgression(forMatch match: MatchData, time: TimeInterval) {
        Defaults[.watchProgression][match._id] = time
    }

    func saveHighlightsWatched(forMatch match: MatchData) {
        Defaults[.highlights][match._id] = true
    }

    func saveGameIndex(index: Int) {
        Defaults[.gameIndex] = index
    }

    func getGameIndex() -> Int {
        return Defaults[.gameIndex]
    }

    func getProgressionForMatch(match: MatchData) -> TimeInterval? {
        return Defaults[.watchProgression][match._id] as? TimeInterval
    }

    func getHighlightsWatchedForMatch(match: MatchData) -> Bool {
        let watched = Defaults[.highlights][match._id] as? Bool
        if watched == nil {
            return false
        }
        return true
    }
}

