//
//  Event.swift
//  Event Vods
//
//  Created by Julien Saad on 2018-02-11.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import Foundation

class Event: Decodable {
    let updatedAt: Date?
    let name: String
    let game: Game
    let slug: String
    let subtitle: String?
    let startDate: Date?
    let endDate: Date?
    let logo: String?
    let status: String?

}
