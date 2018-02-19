//
//  EventSection.swift
//  Event Vods
//
//  Created by Julien Saad on 2018-02-17.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit

class EventSection: Decodable {
    let _id: String?
    let title: String?

    let modules: [EventModule]?
}
