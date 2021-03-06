
/*
 * @nixzhu (zhuhongxu@gmail.com)
 */

public struct Indentation {
    private let level: Int
    private let unit: String

    public static var `default`: Indentation {
        return Indentation(level: 0, unit: "    ")
    }

    var value: String {
        return String(repeating: unit, count: level)
    }
    var deeper: Indentation {
        return Indentation(level: level + 1, unit: unit)
    }
}
