//
//  YoutubeLink.swift
//  Event Vods
//
//  Created by Julien Saad on 2018-02-17.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit

class YoutubeLink: Decodable {
    let gameStart: String?
    let picksBans: String?

    var validUrl: String? {
        if let gameStart = gameStart {
            return gameStart
        }
        if let picksBans = picksBans {
            return picksBans
        }
        return nil
    }
}
