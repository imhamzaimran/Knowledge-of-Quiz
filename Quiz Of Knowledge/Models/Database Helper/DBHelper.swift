//
//  DBHelper.swift
//  Quiz Of Knowledge
//
//  Created by Intern on 09/10/2020.
//

import Foundation
import SQLite3

class DBHelper{
    
    let dbName  = "QuizOfKnowledge.sqlite"
    var db:OpaquePointer?
    
    private func getDBPath()->URL{
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(dbName)
        return fileURL
    }
    
    internal func copyDatabaseIfNeeded() {
        // Move database file from bundle to documents folder
        
        let fileManager = FileManager.default
        guard let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let finalDatabaseURL = documentsUrl.appendingPathComponent(dbName)
        
        do {
            if !fileManager.fileExists(atPath: finalDatabaseURL.path) {
                print("DB does not exist in documents folder")
                
                if let dbFilePath = Bundle.main.path(forResource: "QuizOfKnowledge", ofType: "sqlite") {
                    try fileManager.copyItem(atPath: dbFilePath, toPath: finalDatabaseURL.path)
                } else {
                    print("Uh oh - ramzan.sqlite is not in the app bundle")
                }
            } else {
                print("Database file found at path: \(finalDatabaseURL.path)")
            }
        } catch {
            print("Unable to copy ramzan.db: \(error)")
        }
    }
    
    internal func openDatabase() {
        
        let dbFilePath = getDBPath()
        if sqlite3_open_v2(dbFilePath.path, &db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX | SQLITE_OPEN_CREATE, nil) == SQLITE_OK {
            print("CONNECTION SUCCESSFUL\n")
        } else {
            print("CONNECTION FAILURE")
        }
    }
    
    internal func queryDatabase(with query: String){
//    ->OpaquePointer? {
//        var OperationStatement: OpaquePointer?
//        var ReturnStatement: OpaquePointer?
//        print("querydb \(query)")
//        if sqlite3_prepare_v2(db, query, -1, &OperationStatement, nil) == SQLITE_OK {
//            let id = sqlite3_column_int64(OperationStatement, 0)
//                print("id = \(id); ", terminator: "")
//            ReturnStatement = OperationStatement
//        }
//        return ReturnStatement
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("preparing  error: \(errmsg)")
        }
        do {
            while sqlite3_step(statement) == SQLITE_ROW {
                let item = String(cString: (sqlite3_column_text(statement, 0)))
            }
        }catch {
            print(error.localizedDescription)
        }

        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("finalizing error: \(errmsg)")
        }
    }
    
    internal func executeUpdateDeleteQuery(query: String)->Bool{
        if query == ""{
            return false
        }
        
        var returnValue = false
        var deleteStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &deleteStatement, nil) == SQLITE_OK{
            returnValue = true
        }
        
        if returnValue {
            let result = sqlite3_step(deleteStatement)
            
            if result != SQLITE_DONE{
                print(result)
                sqlite3_finalize(deleteStatement)
            }
        }
        return returnValue
    }
    
    internal func closeDatabase() {
        sqlite3_close(db)
        print("Connection close successfully")
    }
    
}