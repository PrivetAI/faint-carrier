import SwiftUI

// Deep Signal palette — fixed colors so the look never depends on device light/dark mode.
enum SignalTheme {
    static let bg = Color(red: 0.02, green: 0.04, blue: 0.09)
    static let bgDeep = Color(red: 0.01, green: 0.02, blue: 0.05)
    static let card = Color(red: 0.06, green: 0.10, blue: 0.17)
    static let cardRaised = Color(red: 0.09, green: 0.14, blue: 0.22)
    static let stroke = Color(red: 0.16, green: 0.26, blue: 0.36)

    static let accent = Color(red: 0.20, green: 0.85, blue: 0.92)   // cyan signal
    static let accentDim = Color(red: 0.12, green: 0.45, blue: 0.52)
    static let teal = Color(red: 0.30, green: 0.95, blue: 0.78)
    static let amber = Color(red: 1.00, green: 0.78, blue: 0.35)
    static let violet = Color(red: 0.62, green: 0.50, blue: 0.95)

    static let text = Color(red: 0.90, green: 0.96, blue: 1.00)
    static let textDim = Color(red: 0.58, green: 0.70, blue: 0.80)
    static let textFaint = Color(red: 0.40, green: 0.52, blue: 0.62)
}

// Compact number formatting: K, M, B, T, ...
enum SignalFormat {
    private static let units = ["", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"]

    static func short(_ value: Double) -> String {
        if value.isNaN || value.isInfinite { return "0" }
        let v = max(0, value)
        if v < 1000 {
            // Whole numbers below 1000 show without decimals; small fractional shows one decimal.
            if v < 10 && v != v.rounded() { return String(format: "%.1f", v) }
            return String(Int(v.rounded()))
        }
        var idx = 0
        var n = v
        while n >= 1000 && idx < units.count - 1 {
            n /= 1000
            idx += 1
        }
        if n >= 100 { return String(format: "%.0f%@", n, units[idx]) }
        if n >= 10 { return String(format: "%.1f%@", n, units[idx]) }
        return String(format: "%.2f%@", n, units[idx])
    }

    static func rate(_ value: Double) -> String {
        return short(value) + "/s"
    }

    static func mult(_ value: Double) -> String {
        return String(format: "%.2fx", value)
    }
}
