//
//  Event.swift
//  Eventvods
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

    var backgroundImageName: String {
        return String((abs((_id ?? "").hash) % 29) + 1)
    }

    var dateRangeText: String {
        guard let startDate = startDate, let endDate = endDate else {
            return "Some time ago."
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"

        let start = formatter.string(from: startDate)
        let end = formatter.string(from: endDate)

        return "\(start) - \(end)"
    }

    init() {
        _id = nil
        name = ""
        game = Game()
        slug = ""
        subtitle = nil
        startDate = nil
        endDate = nil
        logo = nil
        status = nil
        updatedAt = nil
        contents = nil
    }
}
