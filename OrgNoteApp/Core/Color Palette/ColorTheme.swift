//
//  ColorTheme.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 25.11.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import UIKit

struct ColorTheme {
    let alert: UIColor
    let normal: UIColor
    let text: UIColor
    let attention: UIColor
}

struct Theme {

    static var blueish: ColorTheme {
        return ColorTheme(alert: rgb(255, 185, 151),
                          normal: rgb(132, 59, 98),
                          text: rgb(11, 3, 45),
                          attention: rgb(246, 126, 125))
    }
    
}


private extension Int {

    var colorFloat: CGFloat {
        assert(self >= 0 && self <= 255, "Colors out of range")
        return CGFloat(self) / 255.0
    }

}

func rgb(_ red: Int, _ green: Int, _ blue: Int) -> UIColor {
    return UIColor(displayP3Red: red.colorFloat, green: green.colorFloat, blue: blue.colorFloat, alpha: 1)
}
