//
//  EventSection.swift
//  Eventvods
//
//  Created by Julien Saad on 2018-02-17.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit

class EventSection: Decodable {

    private enum CodingKeys : String, CodingKey {
        case id = "_id"
        case modules
        case title
    }

    let id: String
    let title: String
    let modules: [EventModule]

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let id = try container.decodeIfPresent(String.self, forKey: .id) {
            self.id = id
        }
        else {
            self.id = ""
        }

        if let title = try container.decodeIfPresent(String.self, forKey: .title) {
            self.title = title
        }
        else {
            self.title = ""
        }

        do {
            if let data = try container.decodeIfPresent([EventModule].self, forKey: .modules) {
                self.modules = data
            } else {
                self.modules = []
            }
        }
        catch {
            self.modules = []
        }

    }
}
