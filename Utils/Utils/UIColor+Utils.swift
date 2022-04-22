import UIKit

extension UIColor {
    public var hex: String {
        let components = cgColor.components

        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0

        let hexString = String.init(format: "%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))

        return hexString
    }

    public convenience init(hex: String) {
        var rgbValue:UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)

        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: CGFloat(1.0))
    }

    public var text: UIColor {
        var r = CGFloat(0)
        var g = CGFloat(0)
        var b = CGFloat(0)

        guard getRed(&r, green: &g, blue: &b, alpha: nil) else {
            return .label
        }

        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b

        return (luminance > 0.5) ? .black : .white
    }

    public convenience init(light: UIColor, dark: UIColor) {
        self.init {
            switch $0.userInterfaceStyle {
            case .dark: return dark
            case .light: return light
            case .unspecified: return light
            @unknown default: return light
            }
        }
    }

    public static var groupedTableViewBackground: UIColor {
        UIColor(light: .systemGroupedBackground, dark: .black)
    }

    public static var groupedTableViewCellBackground: UIColor {
        UIColor(light: .white, dark: .systemGray6)
    }
}
