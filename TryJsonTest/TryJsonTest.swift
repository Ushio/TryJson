//
//  TryJsonTest.swift
//  TryJsonTest
//
//  Created by Ushio on 2015/08/12.
//  Copyright © 2015年 Ushio. All rights reserved.
//

import XCTest

class TryJsonTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testLiteralAndTake() {
        do {
            let a: Json = "hoge"
            let av: String = try a.take()
            XCTAssertEqual(av, "hoge")
            XCTAssertEqual(a.takeOrNil(), "hoge")
            do {
                let _: Int = try a.take()
                XCTFail()
            } catch {}
            
            let b: Json = 1.5
            let bv: Double = try b.take()
            XCTAssertEqualWithAccuracy(bv, 1.5, accuracy: DBL_EPSILON)
            XCTAssertEqualWithAccuracy(b.takeOrNil()!, 1.5, accuracy: DBL_EPSILON)
            do {
                let _: Bool = try b.take()
                XCTFail()
            } catch {}
            
            let c: Json = 1
            let cv: Int = try c.take()
            XCTAssertEqual(cv, 1)
            XCTAssertEqual(c.takeOrNil(), 1)
            do {
                let _: String = try c.take()
                XCTFail()
            } catch {}
            
            let d: Json = true
            let dv: Bool = try d.take()
            XCTAssertEqual(dv, true)
            XCTAssertEqual(d.takeOrNil(), true)
            do {
                let _: String = try d.take()
                XCTFail()
            } catch {}
            
            let e: Json = nil
            XCTAssertTrue(e.isNull)
            do {
                let _: [Double] = try e.take()
                XCTFail()
            } catch {}
            
            let f: Json = [2, 3, 5, 7, 11]
            let fv: [Int] = try f.take()
            XCTAssertEqual(fv, [2, 3, 5, 7, 11])
            XCTAssertEqual(f.takeOrNil()!, [2, 3, 5, 7, 11])
            do {
                let _: [String:Double] = try f.take()
                XCTFail()
            } catch {}
            
            let g: Json = ["a" : 1, "b" : 2]
            let gv: [String: Int] = try g.take()
            XCTAssertEqual(gv, ["a" : 1, "b" : 2])
            XCTAssertEqual(g.takeOrNil()!, ["a" : 1, "b" : 2])
            do {
                let _: [String] = try g.take()
                XCTFail()
            } catch {}
        } catch {
            XCTFail()
        }
    }
}
