import Foundation

public extension Double {
    /// Returns a clean, calculator-friendly display string.
    /// - NaN/Infinity are mapped to `"Error"` / infinities.
    /// - Integers are displayed without a trailing `.0`.
    var displayString: String {
        if isNaN { return "Error" }
        if isInfinite { return sign == .minus ? "-∞" : "∞" }

        // If the value is (close enough to) an integer, show it without decimals.
        if self == rounded(), abs(self) < 1e15 {
            return String(format: "%.0f", self)
        }

        // Otherwise trim trailing zeros and keep enough significant digits for
        // scientific accuracy checks (e.g., PI within ~1e-10).
        return String(format: "%.15g", self)
    }
}

