import Foundation

enum ProtocolCodec {
    static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.outputFormatting = []
        return e
    }()

    static let decoder = JSONDecoder()

    static func encode(_ object: [String: Any]) throws -> Data {
        try JSONSerialization.data(withJSONObject: object, options: [])
    }

    static func decodeEnvelope(from data: Data) -> SocketEnvelope? {
        return try? decoder.decode(SocketEnvelope.self, from: data)
    }

    static func decodeDictionary(from value: JSONValue?) -> [String: JSONValue] {
        return value?.objectValue ?? [:]
    }

    static func decodeArray(from value: JSONValue?) -> [JSONValue] {
        return value?.arrayValue ?? []
    }
}
