import XCTest

import RDBC
import RDBCSQLite

extension SyncResultSet {
    func at<T>(index: Int, as: T.Type) throws -> T {
        return try next()![index]! as! T
    }
    
    func at<T>(index: Int) throws -> T {
        return try at(index: index, as: T.self)
    }
    
    func count() throws -> Int {
        return try at(index: 0, as: Int.self)
    }
}

class ExecuteTests: XCTestCase {
    lazy var connection: SyncConnection = try! {
        let driver = SQLiteDriver()
        let connection = try driver.connect(url: "sqlite://memory", params: [:])
        
        try connection.execute(query: "CREATE TABLE person(id INTEGER PRIMARY KEY AUTOINCREMENT, firstname TEXT, lastname TEXT);", parameters: [], named: [:])
        
        try connection.execute(query: "INSERT INTO person(firstname, lastname) VALUES(?, ?);", parameters: ["John", "Lennon"], named: [:])
        try connection.execute(query: "INSERT INTO person(firstname, lastname) VALUES(@first, :last);", parameters: [], named: [":last":"McCartney", "@first": "Paul"])
        
        return connection
    }()
    
    let upsert = "UPDATE person " +
        "SET firstname = 'Ringo', lastname = 'Starr' " +
        "WHERE firstname IS 'John1'; " +
        
        "INSERT INTO person (firstname, lastname) " +
        "SELECT 'Ringo', 'Starr' " +
        "WHERE (Select Changes() = 0);"
    
    func testInsertDelete() throws {
        let params = ["John", "Doe"]
        
        let insert = "INSERT INTO person (firstname, lastname) " +
        "VALUES (?, ?)"
        
        let rsi = try connection.execute(query: insert, parameters: params, named: [:])
        try XCTAssertEqual(rsi!.count(), 1)
        
        let delete = "DELETE FROM person " +
        "WHERE lastname IS ?"
        
        let rsd1 = try connection.execute(query: delete, parameters: Array(params.dropFirst()), named: [:])
        try XCTAssertEqual(rsd1!.count(), 1)
        
        let rsd2 = try connection.execute(query: delete, parameters: Array(params.dropFirst()), named: [:])
        try XCTAssertEqual(rsd2!.count(), 0)
    }
    
    /*func testExecute() throws {
        try connection.execute(query: upsert, parameters: [], named: [:])
        let result = try connection.execute(query: "SELECT firstname FROM person WHERE id IS 1", parameters: [], named: [:])!
        
        XCTAssertEqual(try result.next()![0]! as! String, "Ringo")
	}*/
}
