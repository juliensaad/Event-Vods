//
//  String+Vods.swift
//  Eventvods
//
//  Created by Julien Saad on 2018-03-03.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import Foundation

extension String {
    func getNumberOfSeconds() -> TimeInterval {
        var timeString = self

        var total: TimeInterval = 0
        if timeString.contains("h") {
            let hours = timeString.components(separatedBy: "h").first
            if let hours = hours {
                timeString = timeString.replacingOccurrences(of: "\(hours)h", with: "")
                total += TimeInterval(hours)! * 3600
            }
        }

        if timeString.contains("m") {
            let minutes = timeString.components(separatedBy: "m").first
            if let minutes = minutes {
                timeString = timeString.replacingOccurrences(of: "\(minutes)m", with: "")
                total += TimeInterval(minutes)! * 60
            }
        }

        if timeString.contains("s") {
            let seconds = timeString.components(separatedBy: "s").first
            if let seconds = seconds {
                timeString = timeString.replacingOccurrences(of: "\(seconds)s", with: "")
                total += TimeInterval(seconds)!
            }
        }


        return total
    }

    static func getRedirectURL(url: String, withCompletion completion: @escaping (String?) -> Void) {
        if url.contains("youtube") || url.contains("youtu.be") {
            completion(url)
        }
        else {
            let loader = URLRedirectLoader()
            loader.fetchRedirect(url: url, completion: completion)
        }
    }

    func getQueryStringParameter(_ param: String) -> String? {
        guard let url = URLComponents(string: self) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }

    static func fromTimeInterval(_ interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
