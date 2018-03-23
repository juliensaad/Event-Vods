//
//  GradientView.swift
//  Eventvods
//
//  Created by Julien Saad on 2018-03-22.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit


class GradientView: UIView {

    private let gradient : CAGradientLayer = CAGradientLayer()

    var startColor: UIColor = UIColor(white:0, alpha:0.3)
    var endColor: UIColor = UIColor(white:0, alpha:0.6)

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        self.gradient.frame = self.bounds
    }

    override public func draw(_ rect: CGRect) {
        self.gradient.frame = self.bounds
        self.gradient.colors = [startColor.cgColor, endColor.cgColor]
        self.gradient.startPoint = CGPoint.init(x: 1, y: 0)
        self.gradient.endPoint = CGPoint.init(x: 0.2, y: 1)
        if self.gradient.superlayer == nil {
            self.layer.insertSublayer(self.gradient, at: 0)
        }
    }
}

