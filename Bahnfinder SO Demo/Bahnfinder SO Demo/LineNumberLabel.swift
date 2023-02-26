//
//  LineNumberswift
//  MVG App
//
//  Created by Victor Lobe on 29.01.23.
//

import UIKit
import TripKit

class LineNumberLabel: UILabel {
    
    var foregroundColor = UInt32()
    var backgroundColorC = UInt32()
    var borderColor = UInt32()
    var shape = Shape(rawValue: 0)
    
override func awakeFromNib() {
    super.awakeFromNib()
    clipsToBounds = true
    layer.sublayers = nil
    layer.mask = nil
    
    if UserDefaults.standard.bool(forKey: "productSymbolsThemeDetailLine") == true {
        switch UserDefaults.standard.string(forKey: "productSymbolsTheme") {
        case "Einfarbig":
            backgroundColor = UIColor(argb: backgroundColorC)
            textColor = UIColor(argb: foregroundColor)
            layer.borderWidth = 2
            layer.borderColor = UIColor(argb: borderColor).cgColor
        case "Neon":
            backgroundColor = .clear
            textColor = UIColor(argb: foregroundColor)
            if borderColor == 0 {
                layer.borderWidth = 2
                layer.borderColor = UIColor(argb: backgroundColorC).cgColor
            } else {
                layer.borderWidth = 2
                layer.borderColor = UIColor(argb: borderColor).cgColor
            }
        case "Glas":
            backgroundColor = UIColor(argb: backgroundColorC)
            textColor = UIColor(argb: foregroundColor)
            layer.borderWidth = 2
            layer.borderColor = UIColor(argb: borderColor).cgColor
        default: break
        }
    } else {
        backgroundColor = UIColor(argb: backgroundColorC)
        textColor = UIColor(argb: foregroundColor)
        layer.borderWidth = 2
        layer.borderColor = UIColor(argb: borderColor).cgColor
    }
    if isColorInRange(color: textColor, redMin: 0, redMax: 5, greenMin: 0, greenMax: 5, blueMin: 0, blueMax: 5) == true {
        //Black
        textColor = .white
    }
    
    if isColorInRange(color: textColor, redMin: 250, redMax: 255, greenMin: 250, greenMax: 255, blueMin: 250, blueMax: 255) == true {
        //White
        textColor = .white
    }
}

override func layoutSubviews() {
    super.layoutSubviews()
    awakeFromNib()
    if shape == .circle {
        if borderColor == 0 {
            roundCornersWithBorder(corners: .allCorners, radius: 360, borderWidth: layer.borderWidth, borderColor: UIColor(argb: backgroundColorC))
        } else {
            roundCornersWithBorder(corners: .allCorners, radius: 360, borderWidth: layer.borderWidth, borderColor: UIColor(argb: borderColor))
        }

    }
}

override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    awakeFromNib()
}
}
