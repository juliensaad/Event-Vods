//
//  Event.swift
//  Event Vods
//
//  Created by Julien Saad on 2018-02-11.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import Foundation

class Event: Decodable {
    let _id: String?
    let name: String
    let game: Game
    let slug: String
    let subtitle: String?
    let startDate: Date?
    let endDate: Date?
    let logo: String?
    let status: String?
    let updatedAt: Date?

    let contents: [EventSection]?

//    private enum CodingKeys : String, CodingKey {
//        case test
//    }

    var backgroundImageName: String {
        return String(abs((_id ?? "").hash) % 13)
    }

//    required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        if let test = try container.decodeIfPresent(String.self, forKey: .test) {
//            self.test = test
//        } else {
//            self.test = "No value"
//        }
//    }
}
