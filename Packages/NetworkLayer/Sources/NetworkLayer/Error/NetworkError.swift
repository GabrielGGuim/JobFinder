//
//  NetworkError.swift
//  NetworkLayer
//
//  Created by Gabriel Gonçalves Guimarães on 09/07/26.
//
import Foundation
import SwiftUI

public enum NetworkError: LocalizedError {
    
    case genericError
    case custom(String)
    case response(statusCode: Int, message: String)
    
    public var errorDescription: String? {
        switch self {
        case .genericError:
            return "Esse serviço está indisponível"
            
        case .custom(let message):
            return message
            
        case .response(_, let message):
            return message
        }
    }
    
    public var statusCode: Int? {
        switch self {
        case .response(let code, _):
            return code
        default:
            return nil
        }
    }
}

enum ErrorVerifier {
    
    static func build(
        from response: URLResponse,
        data: Data? = nil,
        statusCodeValidate: [ClosedRange<Int>] = [200...299],
        acceptedErrorText: Bool = false
    ) async throws {
        
        guard let response = response as? HTTPURLResponse else {
            throw NetworkError.genericError
        }
        
        switch response.statusCode {
        case 200:
            await NetworkLayer.shared.notify(.success)
            
        case 401:
            await NetworkLayer.shared.notify(.unauthorized)
            
        case 403:
            await NetworkLayer.shared.notify(.forbidden)
            
        case 302, 426:
            await NetworkLayer.shared.notify(.outdated)
            
        default:
            break
        }
        
        guard statusCodeValidate.contains(where: { $0.contains(response.statusCode) }) else {
            
            let message = acceptedErrorText
            ? String(data: data ?? Data(), encoding: .utf8) ?? "Esse serviço está indisponível"
            : "Esse serviço está indisponível"
            
            throw NetworkError.response(
                statusCode: response.statusCode,
                message: message
            )
        }
    }
    
    static func build(from error: Error) -> Error {

            if let error = error as? NetworkError {
                return error
            }

            return NetworkError.genericError
        }
}

public enum HttpResult: Int {
    case success
    case unauthorized
    case forbidden
    case outdated
}
