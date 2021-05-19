//
//  Book.swift
//  MobileApplication
//
//  Created by Сапбиєв Максим on 5/9/21.
//

import Foundation
import UIKit

struct Books: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case list = "books"
    }

    let list: [Book]

}

@objcMembers
class Book: NSObject, SQLiteDecodable {
    
    enum CodingKeys: String, CodingKey, CaseIterable {

        case title
        case subtitle
        case isbn13
        case price
        case image
        case imageData
        
    }
    
    let title: String
    let subtitle: String
    let isbn13: String
    let price: String
    let image: String
    var imageData: Data? = Data()
    
    init(title: String, subtitle: String, isbn13: String, price: String, image: String) {
        self.title = title
        self.subtitle = subtitle
        self.isbn13 = isbn13
        self.price = price
        self.image = image
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Self.CodingKeys)
        self.title = try container.decode(String.self, forKey: .title)
        self.subtitle = try container.decode(String.self, forKey: .subtitle)
        self.isbn13 = try container.decode(String.self, forKey: .isbn13)
        self.price = try container.decode(String.self, forKey: .price)
        self.image = try container.decode(String.self, forKey: .image)
        if let b64Str = try? container.decodeIfPresent(String.self, forKey: .imageData) {
            if let data = Data(base64Encoded: b64Str, options: .ignoreUnknownCharacters) {
                self.imageData = data
            }
        }
        
    }
    
    var queryValues: [String] {
        return Self.CodingKeys.allCases.map {
            let propertyValue = value(forKey: $0.rawValue)
            if let string = propertyValue as? String {
                return "\"\(string)\""
            } else if let data = propertyValue as? Data {
                return "\"\(data.base64EncodedString(options: .lineLength64Characters))\""
            } else {
                return "NULL"
            }
        }
    }
    
    static var queryKeys: [String] = CodingKeys.allCases.map { $0.rawValue }
    static var table: String = {
       return
        """
        CREATE TABLE IF NOT EXISTS Book(
        title CHAR(255) NOT NULL,
        subtitle CHAR(255) NOT NULL,
        isbn13 CHAR(255) PRIMARY KEY NOT NULL,
        price CHAR(255) NOT NULL,
        image CHAR(255) NOT NULL,
        imageData CHAR(20470) NOT NULL
        );
        """
    } ()
    
}
