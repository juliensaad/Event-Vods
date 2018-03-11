//
//  Game.swift
//  Event Vods
//
//  Created by Julien Saad on 2018-02-11.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit

class Game: Decodable, Hashable, CustomStringConvertible {

    static let supportedGames = ["lol", "csgo", "overwatch", "dota", "rocket-league"]
    
    let slug: String
    let icon: String?

    static func colorForSlug(_ slug: String) -> UIColor {
        switch slug {
        case "lol":
            return UIColor.lolGreen

        case "csgo":
            return UIColor.csgo

        case "overwatch":
            return UIColor.overwatch

        case "dota":
            return UIColor.dota

        case "rocket-league":
            return UIColor.rocketLeague

        default:
            return UIColor.lolGreen
        }
    }

    var hashValue: Int {
        return slug.hashValue
    }

    public static func ==(lhs: Game, rhs: Game) -> Bool {
        return lhs.slug == rhs.slug
    }

    var description: String {
        return slug
    }
    
}
