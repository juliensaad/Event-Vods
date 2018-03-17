//
//  EventAPI.swift
//  Event Vods
//
//  Created by Julien Saad on 2018-02-11.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import Foundation
import Siesta

let EventAPI = _EventAPI()
let ImageCache = Service()

class _EventAPI {
    
    // MARK: - Configuration
    private let service = Service(
        baseURL: "https://eventvods.com/api",
        standardTransformers: [.text, .image])
    fileprivate init() {
        #if DEBUG
            LogCategory.enabled = [.network]
//            LogCategory.enabled = LogCategory.common
        #endif

        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
      
        service.configure(EventVods.events.path) {
            // Refresh search results after 10 seconds (Siesta default is 30)
            $0.expirationTime = 10
        }
        
        // –––––– Mapping from specific paths to models ––––––
        service.configureTransformer(EventVods.events.path) {
            try jsonDecoder.decode([Event].self, from: $0.content)
        }
        
        service.configureTransformer(EventVods.game.path + "/*") {
            try jsonDecoder.decode(Event.self, from: $0.content)
        }
    }
    
    func game(_ slug: String) -> Resource {
        return service
            .resource(EventVods.game.path)
            .child(slug)
    }
    
    func events() -> Resource {
        return service
            .resource(EventVods.events.path)
    }
    
}

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
