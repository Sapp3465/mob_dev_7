//
//  SQLStorage.swift
//  MobileApplication
//
//  Created by Сапбиєв Максим on 5/15/21.
//

import Foundation
import SQLite3

class SQLStorage {

    private let pointer: OpaquePointer
    
    init(with pointer: OpaquePointer) {
        self.pointer = pointer
    }

    
    private func createTableIfNeeded<T: SQLiteDecodable>(for entity: T.Type) {
        var createTableStatement: OpaquePointer?
        let createTableString = T.table
        
        if sqlite3_prepare_v2(pointer, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            sqlite3_step(createTableStatement)
        }
        sqlite3_finalize(createTableStatement)
    }

    func insert<T: SQLiteDecodable>(entity: T) {
        self.createTableIfNeeded(for: T.self)
        let insertStatementString =
"""
INSERT INTO \(String(describing: T.self))(\(T.queryKeys.joined(separator: ", "))) VALUES (\(entity.queryValues.joined(separator: ", ")));
"""

        var insertStatement: OpaquePointer?
        if sqlite3_prepare_v2(pointer, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            let id: Int32 = 1
            let name: NSString = "Ray"
            sqlite3_bind_int(insertStatement, 1, id)
            sqlite3_bind_text(insertStatement, 2, name.utf8String, -1, nil)
            sqlite3_step(insertStatement)
        }
        sqlite3_finalize(insertStatement)
    }

    func update<T: SQLiteDecodable>(entity: T, where: String) {
        self.createTableIfNeeded(for: T.self)
        let dict: [String: String] = zip(T.queryKeys, entity.queryValues).reduce(into: [:], { $0[$1.0] = $1.1})
        let insertStatementString =
"""
UPDATE \(String(describing: T.self))
SET \(dict.map { "\($0.key) = \($0.value)"}.joined(separator: ",\n\t") )
WHERE \(String(describing: T.self)).\(`where`) = \"\(entity.value(forKey: `where`) as! String)\";
"""

        var insertStatement: OpaquePointer?
        if sqlite3_prepare_v2(pointer, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            let id: Int32 = 1
            let name: NSString = "Ray"
            sqlite3_bind_int(insertStatement, 1, id)
            sqlite3_bind_text(insertStatement, 2, name.utf8String, -1, nil)
            sqlite3_step(insertStatement)
        }
        sqlite3_finalize(insertStatement)
    }

    func fetch<T: SQLiteDecodable>() -> [T] {
        let queryStatementString = "SELECT * FROM \(String(describing: T.self));"
        
        var objs: [[String: String]] = []
        var queryStatement: OpaquePointer?
        if sqlite3_prepare_v2(pointer, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                var dictionary: [String: String] = [:]
                entityLoop: for i in 0..<Int32(T.queryKeys.count) {
                    guard let queryResultCol1 = sqlite3_column_text(queryStatement, i) else {
                        continue
                    }
                    let name = String(cString: queryResultCol1)
                    dictionary[String(T.queryKeys[Int(i)])] = name
                }
                objs.append(dictionary)
            }
        }
        sqlite3_finalize(queryStatement)

        let data = try! JSONSerialization.data(withJSONObject: objs, options: [])
        return try! JSONDecoder().decode([T].self, from: data)
    }

    

}
