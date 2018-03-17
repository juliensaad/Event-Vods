//
//  View+Vods.swift
//  Eventvods
//
//  Created by Julien Saad on 2018-02-25.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit

extension UIView {
    func borderize() {
        layer.borderColor = UIColor.green.cgColor
        layer.borderWidth = 2
    }

    func borderizeRed() {
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 2
    }
}
