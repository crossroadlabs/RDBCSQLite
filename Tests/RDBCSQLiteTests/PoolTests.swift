//===--- PoolTests.swift ------------------------------------------------------===//
//Copyright (c) 2017 Crossroad Labs s.r.o.
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.
//===----------------------------------------------------------------------===//

import XCTest

import RDBC
import RDBCSQLite

class PoolTests: XCTestCase {
    lazy var pool: Connection = try! {
        let rdbc = RDBC()
        rdbc.register(driver: SQLiteDriver())
        
        return try rdbc.pool(url: "sqlite://memory", params: [:])
    }()
    
    func testPool() throws {
        let rdbc = RDBC()
        rdbc.register(driver: SQLiteDriver())
        
        let pool = try rdbc.pool(url: "sqlite://memory", params: [:])
        
        var counter = 0
        
        (0..<1000).forEach { n in
            let exp = self.expectation(description: "exp: \(n)")
            
            pool.execute(query: "SELECT changes()", parameters: [], named: [:]).onComplete { _ in
                XCTAssertEqual(n, counter)
                
                counter = counter.advanced(by: 1)
                
                exp.fulfill()
            }
        }
        
        self.waitForExpectations(timeout: 1, handler: nil)
    }
}
