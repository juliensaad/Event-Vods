//
//  String+Vods.swift
//  Event Vods
//
//  Created by Julien Saad on 2018-03-03.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import Foundation

extension String {
    func getNumberOfSeconds() -> Int {
        var timeString = self

        var total = 0
        if timeString.contains("h") {
            let hours = timeString.components(separatedBy: "h").first
            if let hours = hours {
                timeString = timeString.replacingOccurrences(of: "\(hours)h", with: "")
                total += Int(hours)! * 3600
            }
        }

        if timeString.contains("m") {
            let minutes = timeString.components(separatedBy: "m").first
            if let minutes = minutes {
                timeString = timeString.replacingOccurrences(of: "\(minutes)m", with: "")
                total += Int(minutes)! * 60
            }
        }

        if timeString.contains("s") {
            let seconds = timeString.components(separatedBy: "s").first
            if let seconds = seconds {
                timeString = timeString.replacingOccurrences(of: "\(seconds)s", with: "")
                total += Int(seconds)!
            }
        }


        return total
    }

    static func getRedirectURL(url: String, withCompletion completion: @escaping (String?) -> Void) {
        if url.contains("youtube") {
            completion(url)
        }
        else {
            let loader = URLRedirectLoader()
            loader.fetchRedirect(url: url, completion: completion)
        }
    }
}
