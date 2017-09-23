
/*
 * @nixzhu (zhuhongxu@gmail.com)
 */

public struct Meta: Codable {
    let isPublic: Bool
    let modelType: String
    let codable: Bool
    let declareVariableProperties: Bool
    let jsonDictionaryName: String
    let propertyMap: [String: String]
    let arrayObjectMap: [String: String]
    let propertyTypeMap: [String: String]

    public struct EnumProperty: Codable {
        public let name: String
        public let cases: [String: String?]
    }

    let enumProperties: [EnumProperty]?
    
    enum CodingKeys: String, CodingKey {
        case isPublic = "public"
        case modelType = "model_type"
        case codable
        case declareVariableProperties = "declare_variable_properties"
        case jsonDictionaryName = "json_dictionary_name"
        case propertyMap = "property_map"
        case arrayObjectMap = "array_map"
        case propertyTypeMap = "property_type_map"
        case enumProperties = "enum_property"
    }

    var removedKeySet: Set<String> {
        var keySet: Set<String> = []
        for (key, value) in propertyMap {
            if value.isEmpty || value == "_" {
                keySet.insert(key)
            }
        }
        return keySet
    }

    func contains(enumPropertyKey: String ) -> Bool {
        guard let enumProperties = enumProperties else { return false }
        for enumProperty in enumProperties {
            if enumProperty.name == enumPropertyKey {
                return true
            }
        }
        return false
    }

    func enumCases(key: String) -> [String: String?]? {
        guard let enumProperties = enumProperties else { return nil }
        for enumProperty in enumProperties {
            if enumProperty.name == key {
                return enumProperty.cases
            }
        }
        return nil
    }

    public static var `default`: Meta {
        return Meta(
            isPublic: false,
            modelType: "struct",
            codable: false,
            declareVariableProperties: false,
            jsonDictionaryName: "[String: Any]",
            propertyMap: [:],
            arrayObjectMap: [:],
            propertyTypeMap: [:],
            enumProperties: []
        )
    }

    var publicCode: String {
        return isPublic ? "public " : ""
    }

    var declareKeyword: String {
        return declareVariableProperties ? "var" : "let"
    }
}

extension Meta {
    static let swiftKeywords: Set<String> = [
        "Any",
        "as",
        "associatedtype",
        "break",
        "case",
        "catch",
        "class",
        "continue",
        "default",
        "defer",
        "deinit",
        "do",
        "else",
        "enum",
        "extension",
        "fallthrough",
        "false",
        "fileprivate",
        "for",
        "func",
        "guard",
        "if",
        "import",
        "in",
        "init",
        "inout",
        "internal",
        "is",
        "let",
        "nil",
        "open",
        "operator",
        "private",
        "protocol",
        "public",
        "repeat",
        "rethrows",
        "return",
        "Self",
        "self",
        "static",
        "struct",
        "subscript",
        "super",
        "switch",
        "Type",
        "throw",
        "throws",
        "true",
        "try",
        "typealias",
        "var",
        "where",
        "while"
    ]
}

extension Meta {
    public static var enumRawValueSeparator: String = "<@_@>"
}
