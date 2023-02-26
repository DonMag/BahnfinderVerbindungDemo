//
//  LineHalfTriangleView.swift
//  MVG App
//
//  Created by Victor Lobe on 06.02.23.
//

import UIKit
import TripKit

class LineHalfTriangleView: UIView {
    var topColor = UInt32()
    var bottomColor = UInt32()
    var shape = Shape(rawValue: 0)
    var borderColor = UInt32()
    
    override func draw(_ rect: CGRect) {
        backgroundColor = .clear
        let pathBottom = UIBezierPath()
        pathBottom.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        pathBottom.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        pathBottom.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        pathBottom.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        if UserDefaults.standard.string(forKey: "productSymbolsTheme") == "Neon" {
            UIColor(argb: bottomColor).setStroke()
            pathBottom.lineWidth = 2
            pathBottom.stroke()
        } else {
            UIColor(argb: bottomColor).setFill()
            pathBottom.fill()
        }
        let pathTop = UIBezierPath()
        pathTop.move(to: CGPoint(x: rect.minX, y: rect.minY))
        pathTop.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        pathTop.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        pathTop.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        if UserDefaults.standard.string(forKey: "productSymbolsTheme") == "Neon" {
            UIColor(argb: topColor).setStroke()
            pathTop.lineWidth = 2
            pathTop.stroke()
        } else {
            UIColor(argb: topColor).setFill()
            pathTop.fill()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        awakeFromNib()
        if shape == .circle {
            if borderColor == 0 {
                roundCornersWithBorder(corners: .allCorners, radius: 360, borderWidth: 0, borderColor: UIColor(argb: topColor))
            } else {
                roundCornersWithBorder(corners: .allCorners, radius: 360, borderWidth: 2, borderColor: UIColor(argb: borderColor))
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = true
        layer.sublayers = nil
        layer.mask = nil
    }
    
}
