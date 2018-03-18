//
//  EventModule.swift
//  Eventvods
//
//  Created by Julien Saad on 2018-02-17.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit

struct EventModule: Decodable {
    let _id: String
    var title: String
    let date: Date

    let matches: [String]?
    var matches2: [Match]
}
