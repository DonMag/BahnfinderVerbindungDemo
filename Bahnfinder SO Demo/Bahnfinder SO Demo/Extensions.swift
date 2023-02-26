//
//  Extensions.swift
//  MVG App
//
//  Created by Victor Lobe on 13.12.22.
//

import Foundation
import UIKit
import TripKit

extension UIImageView {
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}

extension UIImage {
    public func image(withImageColor color: UIColor) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(CGBlendMode.normal)
        let rect: CGRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context.clip(to: rect, mask: self.cgImage!)
        color.setFill()
        context.fill(rect)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

public func isKeyPresentInUserDefaults(key: String) -> Bool {
    return UserDefaults.standard.object(forKey: key) != nil
}





public func currentProvider() -> NetworkProvider {
        UserDefaults.standard.set("DB", forKey: "selectedService")
        return DbProvider(
              apiAuthorization: [
                    "type": "AID",
                    "aid": "n91dB8Z77MLdoR0K"
              ],
              requestVerification: AbstractHafasClientInterfaceProvider.RequestVerification.checksum(salt: "bdI8UVj40K5fvxwf")
        )
}

public func setProvider(provider: String) {
    UserDefaults.standard.set(provider, forKey: "selectedService")
}

public func checkIfProviderChanged() -> Bool {
    if UserDefaults.standard.string(forKey: "lastProviderAtStartup") == currentProvider().id.rawValue {
        return false
    } else {
        //Provider got changed
        return true
    }
}

public func getMinutesDifferenceFromTwoDates(start: Date, end: Date) -> Int
{

    let diff = Int(end.timeIntervalSince1970 - start.timeIntervalSince1970)

    let hours = diff / 3600
    let minutes = (diff - hours * 3600) / 60
    return minutes
}

public func rearrange<T>(array: Array<T>, fromIndex: Int, toIndex: Int) -> Array<T>{
    var arr = array
    let element = arr.remove(at: fromIndex)
    arr.insert(element, at: toIndex)

    return arr
}

extension TimeInterval {
    func stringFromTimeIntervalWithText() -> String {
        let time = NSInteger(self)
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
        if hours > 0 {
            return String(format:"%d:%02d Std.", hours, minutes)
        } else {
            return String(format:"%d Min.", minutes)
        }
    }
}

extension TimeInterval {
    func stringFromTimeIntervalOnlyNumber() -> String {
        let time = NSInteger(self)
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
        if hours > 0 {
            return String(format:"%d:%02d", hours, minutes)
        } else {
            return String(format:"%d", minutes)
        }
    }
}

extension Date {
    func stringFromDate() -> String {
        let currentDate = Date()
        let timeInterval = currentDate.timeIntervalSince(self)
        let time = NSInteger(timeInterval)
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
        if hours > 0 {
            return String(format:"%d:%02d Std.", hours, minutes)
        } else {
            return String(format:"%d Min.", minutes)
        }
    }
}


extension UIView {
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}



extension UIView {
    func roundCornersWithBorder(corners:UIRectCorner, radius: CGFloat, borderWidth: CGFloat, borderColor: UIColor) {
        let shapeLayer = CAShapeLayer()
        let path = UIBezierPath(roundedRect: self.bounds.insetBy(dx: borderWidth, dy: borderWidth), byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = borderColor.cgColor
        shapeLayer.lineWidth = borderWidth
        shapeLayer.path = path.cgPath
        self.layer.addSublayer(shapeLayer)
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

extension UIView {
    func addBorder(width: CGFloat, color: UIColor) {
        let border = CALayer()
        border.borderWidth = width
        border.borderColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        self.layer.addSublayer(border)
    }
}

import UIKit

import UIKit

extension UIImage {
    func detectBordersAndDrawLine(width: CGFloat, color: UIColor) -> UIImage? {
        let image = cgImage!
        let width = Int(size.width)
        let height = Int(size.height)
        let bytesPerRow = width * 4
        let imageData = UnsafeMutablePointer<UInt8>.allocate(capacity: width * height * 4)
        defer {
            imageData.deallocate()
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: imageData,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: bytesPerRow,
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

        // Detect edges
        // ...

        // Draw line
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(CGFloat(width))
        context.move(to: CGPoint(x: 0, y: 0))
        context.addLine(to: CGPoint(x: width, y: 0))
        context.addLine(to: CGPoint(x: width, y: height))
        context.addLine(to: CGPoint(x: 0, y: height))
        context.addLine(to: CGPoint(x: 0, y: 0))
        context.strokePath()

        let newImage = context.makeImage()!
        return UIImage(cgImage: newImage)
    }
}
func isColorInRange(color: UIColor, redMin: Int, redMax: Int, greenMin: Int, greenMax: Int, blueMin: Int, blueMax: Int) -> Bool {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0

    color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

    let redValue = Int(red * 255)
    let greenValue = Int(green * 255)
    let blueValue = Int(blue * 255)

    if redValue >= redMin && redValue <= redMax && greenValue >= greenMin && greenValue <= greenMax && blueValue >= blueMin && blueValue <= blueMax {
        return true
    } else {
        return false
    }
}

func productToTransportType(product: Product) -> TransportType {
    switch product {
    case .highSpeedTrain:
        return .ice
    case .regionalTrain:
        return .regio
    case .suburbanTrain:
        return .sbahn
    case .subway:
        return .ubahn
    case .tram:
        return .tram
    case .bus:
        return .bus
    case .ferry:
        return .ferry
    case .cablecar:
        return .seilbahn
    case .onDemand:
        return .rufbus
    default:
        return .empty
    }
}


enum TransportType {
    case bus
    case ubahn
    case sbahn
    case tram
    case rufbus
    case walk
    case ferry
    case regio
    case seilbahn
    case ice
    case empty
}

enum DesignPack {
    case automatic
    case einfarbig
    case neon
    case glas
}

func getProductSymbol(productType: TransportType, designPack: DesignPack) -> UIImage? {

    if designPack == .automatic {
        let defaults = UserDefaults.standard
        let UDDesignPack = defaults.string(forKey: "productSymbolsTheme")
        switch UDDesignPack {
        case "Einfarbig":
            switch productType {
            case .bus:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemCyan])
                return UIImage(systemName: "b.circle.fill")!.applyingSymbolConfiguration(config)
            case .ubahn:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemBlue])
                return UIImage(systemName: "u.square.fill")!.applyingSymbolConfiguration(config)
            case .sbahn:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemGreen])
                return UIImage(systemName: "s.circle.fill")!.applyingSymbolConfiguration(config)
            case .tram:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemRed])
                return UIImage(systemName: "t.square.fill")!.applyingSymbolConfiguration(config)
            case .rufbus:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemYellow])
                return UIImage(systemName: "b.circle.fill")!.applyingSymbolConfiguration(config)
            case .seilbahn:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemPink])
                return UIImage(systemName: "g.square.fill")!.applyingSymbolConfiguration(config)
            case .regio:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemIndigo])
                return UIImage(systemName: "r.square.fill")!.applyingSymbolConfiguration(config)
            case .ferry:
                if #available(iOS 16.1, *) {
                    let config = UIImage.SymbolConfiguration(hierarchicalColor: .systemMint)
                    return UIImage(systemName: "sailboat.circle.fill")!.applyingSymbolConfiguration(config)
                } else {
                    let config = UIImage.SymbolConfiguration(hierarchicalColor: .systemMint)
                    return UIImage(systemName: "ferry.fill")!.applyingSymbolConfiguration(config)
                }
            case .ice:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemRed])
                return UIImage(systemName: "i.square.fill")!.applyingSymbolConfiguration(config)
            case .walk:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .lightGray])
                return UIImage(systemName: "figure.walk.diamond.fill")!.applyingSymbolConfiguration(config)
            case .empty:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemRed])
                return UIImage(systemName: "questionmark.square.fill")!.applyingSymbolConfiguration(config)
            default:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemRed])
                return UIImage(systemName: "questionmark.square.fill")!.applyingSymbolConfiguration(config)
            }
        case "Neon":
            switch productType {
            case .bus:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemCyan])
                return UIImage(systemName: "b.circle")!.applyingSymbolConfiguration(config)
            case .ubahn:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemBlue])
                return UIImage(systemName: "u.square")!.applyingSymbolConfiguration(config)
            case .sbahn:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemGreen])
                return UIImage(systemName: "s.circle")!.applyingSymbolConfiguration(config)
            case .tram:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemRed])
                return UIImage(systemName: "t.square")!.applyingSymbolConfiguration(config)
            case .rufbus:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemYellow])
                return UIImage(systemName: "b.circle")!.applyingSymbolConfiguration(config)
            case .seilbahn:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemPink])
                return UIImage(systemName: "g.square")!.applyingSymbolConfiguration(config)
            case .regio:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemIndigo])
                return UIImage(systemName: "r.square")!.applyingSymbolConfiguration(config)
            case .ferry:
                if #available(iOS 16.1, *) {
                    let config = UIImage.SymbolConfiguration(hierarchicalColor: .systemMint)
                    return UIImage(systemName: "sailboat.circle.fill")!.applyingSymbolConfiguration(config)
                } else {
                    let config = UIImage.SymbolConfiguration(hierarchicalColor: .systemMint)
                    return UIImage(systemName: "ferry.fill")!.applyingSymbolConfiguration(config)
                }
            case .ice:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemRed])
                return UIImage(systemName: "i.square")!.applyingSymbolConfiguration(config)
            case .walk:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .lightGray])
                return UIImage(systemName: "figure.walk.diamond")!.applyingSymbolConfiguration(config)
            case .empty:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemRed])
                return UIImage(systemName: "questionmark.square")!.applyingSymbolConfiguration(config)
            default:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemRed])
                return UIImage(systemName: "questionmark.square")!.applyingSymbolConfiguration(config)
            }
        case "Glas":
            switch productType {
            case .bus:
                let config = UIImage.SymbolConfiguration(hierarchicalColor: .systemCyan)
                return UIImage(systemName: "b.circle.fill")!.applyingSymbolConfiguration(config)
            case .ubahn:
                let config = UIImage.SymbolConfiguration(hierarchicalColor: .systemBlue)
                return UIImage(systemName: "u.square.fill")!.applyingSymbolConfiguration(config)
            case .sbahn:
                let config = UIImage.SymbolConfiguration(hierarchicalColor: .systemGreen)
                return UIImage(systemName: "s.circle.fill")!.applyingSymbolConfiguration(config)
            case .tram:
                let config = UIImage.SymbolConfiguration(hierarchicalColor: .systemRed)
                return UIImage(systemName: "t.square.fill")!.applyingSymbolConfiguration(config)
            case .rufbus:
                let config = UIImage.SymbolConfiguration(hierarchicalColor: .systemYellow)
                return UIImage(systemName: "b.circle.fill")!.applyingSymbolConfiguration(config)
            case .seilbahn:
                let config = UIImage.SymbolConfiguration(hierarchicalColor: .systemPink)
                return UIImage(systemName: "g.square.fill")!.applyingSymbolConfiguration(config)
            case .regio:
                let config = UIImage.SymbolConfiguration(hierarchicalColor: .systemIndigo)
                return UIImage(systemName: "r.square.fill")!.applyingSymbolConfiguration(config)
            case .ferry:
                if #available(iOS 16.1, *) {
                    let config = UIImage.SymbolConfiguration(hierarchicalColor: .systemMint)
                    return UIImage(systemName: "sailboat.circle.fill")!.applyingSymbolConfiguration(config)
                } else {
                    let config = UIImage.SymbolConfiguration(hierarchicalColor: .systemMint)
                    return UIImage(systemName: "ferry.fill")!.applyingSymbolConfiguration(config)
                }
            case .ice:
                let config = UIImage.SymbolConfiguration(hierarchicalColor: .systemRed)
                return UIImage(systemName: "i.square.fill")!.applyingSymbolConfiguration(config)
            case .walk:
                let config = UIImage.SymbolConfiguration(hierarchicalColor: .lightGray)
                return UIImage(systemName: "figure.walk.diamond.fill")!.applyingSymbolConfiguration(config)
            case .empty:
                let config = UIImage.SymbolConfiguration(hierarchicalColor: .systemRed)
                return UIImage(systemName: "questionmark.square.fill")!.applyingSymbolConfiguration(config)
            default:
                let config = UIImage.SymbolConfiguration(hierarchicalColor: .systemRed)
                return UIImage(systemName: "questionmark.square.fill")!.applyingSymbolConfiguration(config)
                
            }
        default:
            return nil
        }
    } else {
        switch designPack {
        case .einfarbig:
            switch productType {
            case .bus:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemCyan])
                return UIImage(systemName: "b.circle.fill")!.applyingSymbolConfiguration(config)
            case .ubahn:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemBlue])
                return UIImage(systemName: "u.square.fill")!.applyingSymbolConfiguration(config)
            case .sbahn:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemGreen])
                return UIImage(systemName: "s.circle.fill")!.applyingSymbolConfiguration(config)
            case .tram:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemRed])
                return UIImage(systemName: "t.square.fill")!.applyingSymbolConfiguration(config)
            case .rufbus:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemYellow])
                return UIImage(systemName: "b.circle.fill")!.applyingSymbolConfiguration(config)
            case .seilbahn:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemPink])
                return UIImage(systemName: "g.square.fill")!.applyingSymbolConfiguration(config)
            case .regio:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemIndigo])
                return UIImage(systemName: "r.square.fill")!.applyingSymbolConfiguration(config)
            case .ferry:
                if #available(iOS 16.1, *) {
                    let config = UIImage.SymbolConfiguration(hierarchicalColor: .systemMint)
                    return UIImage(systemName: "sailboat.circle.fill")!.applyingSymbolConfiguration(config)
                } else {
                    let config = UIImage.SymbolConfiguration(hierarchicalColor: .systemMint)
                    return UIImage(systemName: "ferry.fill")!.applyingSymbolConfiguration(config)
                }
            case .ice:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemRed])
                return UIImage(systemName: "i.square.fill")!.applyingSymbolConfiguration(config)
            case .walk:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .lightGray])
                return UIImage(systemName: "figure.walk.diamond.fill")!.applyingSymbolConfiguration(config)
            case .empty:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemRed])
                return UIImage(systemName: "questionmark.square.fill")!.applyingSymbolConfiguration(config)
            default:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemRed])
                return UIImage(systemName: "questionmark.square.fill")!.applyingSymbolConfiguration(config)
            }
        case .neon:
            switch productType {
            case .bus:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemCyan])
                return UIImage(systemName: "b.circle")!.applyingSymbolConfiguration(config)
            case .ubahn:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemBlue])
                return UIImage(systemName: "u.square")!.applyingSymbolConfiguration(config)
            case .sbahn:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemGreen])
                return UIImage(systemName: "s.circle")!.applyingSymbolConfiguration(config)
            case .tram:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemRed])
                return UIImage(systemName: "t.square")!.applyingSymbolConfiguration(config)
            case .rufbus:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemYellow])
                return UIImage(systemName: "b.circle")!.applyingSymbolConfiguration(config)
            case .seilbahn:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemPink])
                return UIImage(systemName: "g.square")!.applyingSymbolConfiguration(config)
            case .regio:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemIndigo])
                return UIImage(systemName: "r.square")!.applyingSymbolConfiguration(config)
            case .ferry:
                if #available(iOS 16.1, *) {
                    let config = UIImage.SymbolConfiguration(hierarchicalColor: .systemMint)
                    return UIImage(systemName: "sailboat.circle.fill")!.applyingSymbolConfiguration(config)
                } else {
                    let config = UIImage.SymbolConfiguration(hierarchicalColor: .systemMint)
                    return UIImage(systemName: "ferry.fill")!.applyingSymbolConfiguration(config)
                }
            case .ice:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemRed])
                return UIImage(systemName: "i.square")!.applyingSymbolConfiguration(config)
            case .walk:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .lightGray])
                return UIImage(systemName: "figure.walk.diamond")!.applyingSymbolConfiguration(config)
            case .empty:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemRed])
                return UIImage(systemName: "questionmark.square")!.applyingSymbolConfiguration(config)
            default:
                let config = UIImage.SymbolConfiguration(paletteColors: [.label, .systemRed])
                return UIImage(systemName: "questionmark.square")!.applyingSymbolConfiguration(config)
            }
        case .glas:
            switch productType {
            case .bus:
                let config = UIImage.SymbolConfiguration(hierarchicalColor: .systemCyan)
                return UIImage(systemName: "b.circle.fill")!.applyingSymbolConfiguration(config)
            case .ubahn:
                let config = UIImage.SymbolConfiguration(hierarchicalColor: .systemBlue)
                return UIImage(systemName: "u.square.fill")!.applyingSymbolConfiguration(config)
            case .sbahn:
                let config = UIImage.SymbolConfiguration(hierarchicalColor: .systemGreen)
                return UIImage(systemName: "s.circle.fill")!.applyingSymbolConfiguration(config)
            case .tram:
                let config = UIImage.SymbolConfiguration(hierarchicalColor: .systemRed)
                return UIImage(systemName: "t.square.fill")!.applyingSymbolConfiguration(config)
            case .rufbus:
                let config = UIImage.SymbolConfiguration(hierarchicalColor: .systemYellow)
                return UIImage(systemName: "b.circle.fill")!.applyingSymbolConfiguration(config)
            case .seilbahn:
                let config = UIImage.SymbolConfiguration(hierarchicalColor: .systemPink)
                return UIImage(systemName: "g.square.fill")!.applyingSymbolConfiguration(config)
            case .regio:
                let config = UIImage.SymbolConfiguration(hierarchicalColor: .systemIndigo)
                return UIImage(systemName: "r.square.fill")!.applyingSymbolConfiguration(config)
            case .ferry:
                if #available(iOS 16.1, *) {
                    let config = UIImage.SymbolConfiguration(hierarchicalColor: .systemMint)
                    return UIImage(systemName: "sailboat.circle.fill")!.applyingSymbolConfiguration(config)
                } else {
                    let config = UIImage.SymbolConfiguration(hierarchicalColor: .systemMint)
                    return UIImage(systemName: "ferry.fill")!.applyingSymbolConfiguration(config)
                }
            case .ice:
                let config = UIImage.SymbolConfiguration(hierarchicalColor: .systemRed)
                return UIImage(systemName: "i.square.fill")!.applyingSymbolConfiguration(config)
            case .walk:
                let config = UIImage.SymbolConfiguration(hierarchicalColor: .lightGray)
                return UIImage(systemName: "figure.walk.diamond.fill")!.applyingSymbolConfiguration(config)
            case .empty:
                let config = UIImage.SymbolConfiguration(hierarchicalColor: .systemRed)
                return UIImage(systemName: "questionmark.square.fill")!.applyingSymbolConfiguration(config)
            default:
                let config = UIImage.SymbolConfiguration(hierarchicalColor: .systemRed)
                return UIImage(systemName: "questionmark.square.fill")!.applyingSymbolConfiguration(config)
                
            }
        default:
            return nil
        }
    }
}

//FIXME: Shows last week in days

public func getAutomaticTimeFormat(date: Date) -> String {
    let calendar = Calendar.current
    let today = Date()
    
    if calendar.isDateInToday(date) {
        return timeFormatHHMM.string(from: date)
    } else if calendar.isDateInTomorrow(date) {
        return "Morgen, \(timeFormatHHMM.string(from: date))"
    } else if calendar.isDateInYesterday(date) {
        return "Gestern, \(timeFormatHHMM.string(from: date))"
    } else if calendar.isDate(date, equalTo: today, toGranularity: .weekOfYear) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, HH:mm"
        return dateFormatter.string(from: date)
    } else {
        return timeFormatDHHMM.string(from: date)
    }
}
extension UIColor  {
    var hexa: Int {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return Int(alpha * 255) << 24
        + Int(red   * 255) << 16
        + Int(green * 255) << 8
        + Int(blue  * 255)
    }
}
