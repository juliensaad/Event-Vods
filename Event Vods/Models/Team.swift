//
//  Team.swift
//  Event Vods
//
//  Created by Julien Saad on 2018-02-17.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit

class Team: Decodable, CustomStringConvertible {
    let name: String
    let slug: String?
    let icon: String?
    let tag: String

    init() {
        name = ""
        slug = ""
        icon = ""
        tag = ""
    }

    var description: String {
        return name
    }
}
