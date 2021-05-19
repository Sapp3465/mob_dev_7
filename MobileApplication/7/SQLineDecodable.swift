//
//  SQLineDecodable.swift
//  MobileApplication
//
//  Created by Сапбиєв Максим on 5/15/21.
//

import Foundation

protocol SQLiteDecodable: NSObject, Decodable {

    var queryValues: [String] { get }
    static var queryKeys: [String] { get }
    static var table: String { get }

}
