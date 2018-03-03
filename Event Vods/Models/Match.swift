//
//  Match.swift
//  Event Vods
//
//  Created by Julien Saad on 2018-02-17.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit
import Siesta

class Match: Decodable {

    private enum CodingKeys : String, CodingKey {
        case team1
        case team2
        case data
        case date
    }

    let team1: Team
    let team2: Team
    let date: Date?
    let data: [MatchData]

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
    }

}
