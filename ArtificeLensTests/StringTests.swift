//
//  StringTests.swift
//  ArtificeLensTests
//
//

import XCTest
@testable import ArtificeLens
@testable import UVC

class StringTests: XCTestCase {
    func testExtractProductAndVendor() throws {
        let modelInfo = "UVC Camera VendorID_1452 ProductID_34068"

        let result = try modelInfo.extractCameraInformation()

        XCTAssertEqual(result.productId, 34068)
        XCTAssertEqual(result.vendorId, 1452)
    }

    func testExtractInvalid() throws {
        let modelInfo = "Some random string"

        XCTAssertThrowsError(try modelInfo.extractCameraInformation())
    }
}
