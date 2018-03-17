//
//  UIFont+Vods.swift
//  Eventvods
//
//  Created by Julien Saad on 2018-03-10.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit

extension UIFont {
    class func vodsFontOfSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Avenir", size: size)!
    }

    class func boldVodsFontOfSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Avenir-Black", size: size)!
    }

    class func lightVodsFontOfSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Avenir-Light", size: size)!
    }
}
