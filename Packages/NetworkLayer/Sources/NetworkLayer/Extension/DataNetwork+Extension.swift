//
//  Data.swift
//  NetworkLayer
//
//  Created by Gabriel Gonçalves Guimarães on 09/07/26.
//
import Foundation

extension Data {
    
    func build<Model: Decodable>(to objectType: Model.Type) throws -> Model {
        do {
            return try JSONDecoder().decoder.decode(objectType, from: self)
        } catch {
            dump(error)
            throw error
        }
    }
    
    var prettyString: NSString {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data,
                                                 encoding: String.Encoding.utf8.rawValue)
        else { return NSString() }
        return prettyPrintedString
    }
    
}
