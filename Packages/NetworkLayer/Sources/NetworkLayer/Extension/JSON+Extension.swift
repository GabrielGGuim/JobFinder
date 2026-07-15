import Foundation

extension JSONDecoder {

    var decoder: JSONDecoder {
        let decoder = self
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

extension JSONEncoder {

    var encoder: JSONEncoder {
        let encoder = self
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }
}
