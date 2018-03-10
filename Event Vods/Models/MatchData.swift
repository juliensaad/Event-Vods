//
//  MatchData.swift
//  Event Vods
//
//  Created by Julien Saad on 2018-02-17.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit

class MatchData: Decodable {
    let _id: String
    let rating: Float?
    let youtube: YoutubeLink?
    let placeholder: Bool?
}
