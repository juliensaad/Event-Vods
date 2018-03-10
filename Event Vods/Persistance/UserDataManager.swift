//
//  UserDataManager.swift
//  Event Vods
//
//  Created by Julien Saad on 2018-03-09.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit

extension DefaultsKeys {
    static let watchProgression = DefaultsKey<[String : Any]>("watchProgression")
}

class UserDataManager: NSObject {
    static let shared = UserDataManager()
    let Defaults = UserDefaults(suiteName: "com.juliensaad.shared-defaults")!

    func saveVideoProgression(forMatch match: MatchData, time: TimeInterval) {
        Defaults[.watchProgression][match._id] = time
    }

    func getProgressionForMatch(match: MatchData) -> TimeInterval? {
        return Defaults[.watchProgression][match._id] as? TimeInterval
    }
}

