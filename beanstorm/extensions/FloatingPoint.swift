extension FloatingPoint {
    func isNearlyEqual(to value: Self, precision: Self) -> Bool {
        return abs(self - value) <= precision
    }
}
