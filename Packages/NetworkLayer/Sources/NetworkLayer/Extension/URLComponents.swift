//
//  URLComponents.swift
//  NetworkLayer
//
//  Created by Gabriel Gonçalves Guimarães on 09/07/26.
//


import Foundation

extension URLComponents {
    public func url(removingPercentEncoding: Bool) -> URL? {
        guard let url: URL else {
            return nil
        }
        
        guard removingPercentEncoding,
              let refinedPath: String = url.absoluteString.removingPercentEncoding else {
            return url
        }
        
        return .init(string: refinedPath)
    }
}
