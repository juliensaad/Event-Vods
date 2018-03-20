//
//  Match.swift
//  Eventvods
//
//  Created by Julien Saad on 2018-02-17.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit
import Siesta

class Match: Decodable, CustomStringConvertible {

    private enum CodingKeys : String, CodingKey {
        case team1
        case team2
        case data
        case date
        case hasSpoilers = "spoiler1"
        case team1Match
        case team2Match
    }

    let team1: Team
    let team2: Team
    let date: Date?
    var data: [MatchData]
    var hasSpoilers: Bool = false
    var team1Match: String = "Team 1"
    var team2Match: String = "Team 2"

    var gameSlug: String = "lol"
    var matchTitle: String {
        return "\(team1.tag) vs \(team2.tag)"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        do {
            if let data = try container.decodeIfPresent([MatchData].self, forKey: .data) {
                self.data = data
            } else {
                self.data = []
            }
        }
        catch {
            self.data = []
        }
        
        date = try container.decodeIfPresent(Date.self, forKey: .date)
        let firstTeam = try container.decodeIfPresent(String.self, forKey: .team1Match)
        let secondTeam = try container.decodeIfPresent(String.self, forKey: .team2Match)

        if let firstTeam = firstTeam {
            team1Match = firstTeam
        }

        if let secondTeam = secondTeam {
            team2Match = secondTeam
        }

        if let team1 = try container.decodeIfPresent(Team.self, forKey: .team1) {
            self.team1 = team1
        }
        else {
            self.team1 = Team()
        }
        

        if let team2 = try container.decodeIfPresent(Team.self, forKey: .team2) {
            self.team2 = team2
        }
        else {
            self.team2 = Team()
        }

        if let spoiler = try container.decodeIfPresent(Bool.self, forKey: .hasSpoilers) {
            self.hasSpoilers = spoiler
        }
        else {
            self.hasSpoilers = false
        }
    }

    var watchCount: Int {
        var count = 0
        for match in data {
            if UserDataManager.shared.getProgressionForMatch(match: match) != nil {
                count = count + 1
            }
        }
        return count
    }

    var isFullyWatched: Bool {
        return watchCount == data.count
    }

    var backgroundImageName: String {
        return String(abs(matchTitle.hash) % 13)
    }

    var description: String {
        return "\(team1) vs \(team2)"
    }

}
