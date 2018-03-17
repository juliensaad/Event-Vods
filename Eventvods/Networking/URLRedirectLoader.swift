//
//  URLRedirectLoader.swift
//  Eventvods
//
//  Created by Julien Saad on 2018-03-04.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit

class URLRedirectLoader: NSObject, URLSessionDelegate, URLSessionDataDelegate {

    var session : URLSession!
    var tasks : [URLSessionDataTask : String] = [URLSessionDataTask : String]()
    var completion: ((String?) -> Void)?

    func fetchRedirect(url: String, completion: @escaping (String?) -> Void) {
        self.session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)

        let urlString : String = url.replacingOccurrences(of: "http:/", with: "https:/")
        self.completion = completion

        guard let url = URL(string: urlString) else { return }
        let request : URLRequest = URLRequest(url: url)

        let dataTask : URLSessionDataTask = session.dataTask(with: request)
        self.tasks[dataTask] = urlString

        dataTask.resume()
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.completion?(nil)
        self.completion = nil
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        self.completion?(response.allHeaderFields["Location"] as? String)
        self.completion = nil
        let newDataTask = self.session.dataTask(with: request)
        newDataTask.cancel()
    }

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(URLSession.AuthChallengeDisposition.performDefaultHandling, nil)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(URLSession.AuthChallengeDisposition.performDefaultHandling, nil)
    }

    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if let _ = error {
            self.completion?(nil)
        }
    }
}
