//
//  PlaybackViewController.swift
//  Event Vods
//
//  Created by Julien Saad on 2018-02-17.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit

class PlaybackViewController: UIViewController {

    let url: String
    init(url: String) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var playbackURL: String {
        var embededURL = url.replacingOccurrences(of: "watch?v=", with: "embed/")

        var numberOfSeconds = 0
        if let query = getQueryStringParameter(url: url, param: "t") {
            numberOfSeconds = getNumberOfSeconds(string: query)
            embededURL = embededURL.replacingOccurrences(of: "&t=\(query)", with: "?start=\(numberOfSeconds)")
        }

        return "\(embededURL)&enablejsapi=1&rel=0&playsinline=1&autoplay=1"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let webView = UIWebView(frame: self.view.frame)

        self.view.addSubview(webView)

        webView.allowsInlineMediaPlayback = true
        webView.mediaPlaybackRequiresUserAction = false


        let embededHTML = "<html><body style='margin:0px;padding:0px;'><script type='text/javascript' src='http://www.youtube.com/iframe_api'></script><script type='text/javascript'>function onYouTubeIframeAPIReady(){ytplayer=new YT.Player('playerId',{events:{onReady:onPlayerReady}})}function onPlayerReady(a){a.target.playVideo();}</script><iframe id='playerId' type='text/html' width='\(self.view.frame.size.width)' height='\(self.view.frame.size.height)' src='\(playbackURL)' frameborder='0'></body></html>"

        print("\(playbackURL)")
        // Load your webView with the HTML we just set up
        webView.loadHTMLString(embededHTML, baseURL: Bundle.main.bundleURL)
    }

    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }

    func getNumberOfSeconds(string: String) -> Int {
        var timeString = string

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


}
