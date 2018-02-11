//
//  EventVods.swift
//  Event Vods
//
//  Created by Julien Saad on 2018-02-11.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import Foundation

enum EventVods {
    case events
    case game
}

extension EventVods: Endpoint {
    var base: String {
        return "https://eventvods.com/api"
    }
    
    var path: String {
        switch self {
        case .events:   return "/events"
        case .game:    return "/events/slug/"
        }
    }
}
