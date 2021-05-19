//
//  SqliteManager.swift
//  MobileApplication
//
//  Created by Сапбиєв Максим on 5/9/21.
//

import Foundation
import SQLite3

class SqliteManager {
    
    static let shared = SqliteManager()
    
    lazy var storage: SQLStorage? = {
        return self.openDataBase()
    } ()

    private func openDataBase() -> SQLStorage? {
        var db: OpaquePointer?
        let part1DbPath = try! FileManager.default.url(for: .documentDirectory,
                                                       in: .userDomainMask,
                                                       appropriateFor: nil,
                                                       create: false).appendingPathComponent("asd.db").absoluteString
//        print(part1DbPath)
        if sqlite3_open(part1DbPath, &db) == SQLITE_OK, let db = db {
            return SQLStorage(with: db)
        } else {
            return nil
        }
    }
    
    func closeDataBase(_ pointer: SQLStorage) {
        
    }

}
