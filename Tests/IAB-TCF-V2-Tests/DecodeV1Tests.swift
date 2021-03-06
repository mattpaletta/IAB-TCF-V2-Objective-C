//
//  DecodeV1Tests.swift
//  IAB-TCF-V2-Tests
//
//  Created by Matthew Paletta on 2020-10-22.
//

import XCTest

import IAB_TCF_V2_API

class DecodeV1Tests: XCTestCase {
    private func parse(_ consentString: String) -> SPTIabTCFModel {
        return TestUtils.parse(consentString, version: 1)
    }

    func testDecodeCanDetectVersion() {
        let model = self.parse("BObdrPUOevsguAfDqFENCNAAAAAmeAAA")
        XCTAssertEqual(model.version, 1)
    }

    func testCanConstructV1Properties() {
        let model = self.parse("BObdrPUOevsguAfDqFENCNAAAAAmeAAA")
        XCTAssertEqual(model.version, 1)
        XCTAssertEqual(model.cmpId, 31)
        XCTAssertEqual(model.cmpVersion, 234)
        XCTAssertEqual(model.consentScreen, 5)
        XCTAssertEqual(model.consentCountryCode, "EN")
        XCTAssertEqual(model.created, TestUtils.dateFromFormat("2019-02-04T21:16:05Z"))
        XCTAssertEqual(model.lastUpdated, TestUtils.dateFromFormat("2019-04-09T14:35:10Z"))
        XCTAssertEqual(model.vendorListVersion, 141)
        XCTAssertEqual(model.parsedPurposesConsents, "000000000000000000000000")
    }

    func testAllowedPurposes() {
        let model = self.parse("BOOzQoAOOzQoAAPAFSENCW-AIBA=")
        XCTAssertTrue([1, 2, 3, 4, 5, 15, 24].allSatisfy(model.isPurposeConsentGivenFor(purposeId:)))
    }

    func testBitFieldEncoding() {
        let model = self.parse("BOOzQoAOOzQoAAPAFSENCW-AIBACBAAABCA=")
        XCTAssertTrue([1, 25, 30].allSatisfy(model.isVendorConsentGivenFor(vendorId:)))

        XCTAssertFalse(model.isVendorConsentGivenFor(vendorId: 2))
        XCTAssertFalse(model.isVendorConsentGivenFor(vendorId: 3))
        XCTAssertFalse(model.isVendorConsentGivenFor(vendorId: 31))
        XCTAssertFalse(model.isVendorConsentGivenFor(vendorId: 32))

        XCTAssertFalse(model.isVendorConsentGivenFor(vendorId: -99))
        XCTAssertFalse(model.isVendorConsentGivenFor(vendorId: -1))
        XCTAssertFalse(model.isVendorConsentGivenFor(vendorId: 0))
        XCTAssertFalse(model.isVendorConsentGivenFor(vendorId: 33))
        XCTAssertFalse(model.isVendorConsentGivenFor(vendorId: 34))
        XCTAssertFalse(model.isVendorConsentGivenFor(vendorId: 99))
    }

    func testRangeEncodingDefaultFalse() {
        let model = self.parse("BOOzQoAOOzQoAAPAFSENCW-AIBACCACgACADIAHg")
        XCTAssertTrue([1, 10, 25, 30].allSatisfy(model.isVendorConsentGivenFor(vendorId:)))

        XCTAssertFalse(model.isVendorConsentGivenFor(vendorId: 26))
        XCTAssertFalse(model.isVendorConsentGivenFor(vendorId: 28))
        XCTAssertFalse(model.isVendorConsentGivenFor(vendorId: 31))
        XCTAssertFalse(model.isVendorConsentGivenFor(vendorId: 32))

        // Vendors outside range [1, MaxVendorId] are not allowed
        XCTAssertFalse(model.isVendorConsentGivenFor(vendorId: -99))
        XCTAssertFalse(model.isVendorConsentGivenFor(vendorId: -1))
        XCTAssertFalse(model.isVendorConsentGivenFor(vendorId: 0))
        XCTAssertFalse(model.isVendorConsentGivenFor(vendorId: 33))
        XCTAssertFalse(model.isVendorConsentGivenFor(vendorId: 34))
        XCTAssertFalse(model.isVendorConsentGivenFor(vendorId: 99))
    }

    func testRangeEncodingDefaultTrue() {
        let model = self.parse("BOOzQoAOOzQoAAPAFSENCW-AIBACDACAADABkAHg")

        // Then: correct vendor IDs are allowed
        XCTAssertFalse(model.isVendorConsentGivenFor(vendorId: 1))
        XCTAssertFalse(model.isVendorConsentGivenFor(vendorId: 25))
        XCTAssertFalse(model.isVendorConsentGivenFor(vendorId: 27))
        XCTAssertFalse(model.isVendorConsentGivenFor(vendorId: 30))

        XCTAssertTrue(model.isVendorConsentGivenFor(vendorId: 2))
        XCTAssertTrue(model.isVendorConsentGivenFor(vendorId: 15))
        XCTAssertTrue(model.isVendorConsentGivenFor(vendorId: 31))
        XCTAssertTrue(model.isVendorConsentGivenFor(vendorId: 32))

        // Vendors outside range [1, MaxVendorId] are not allowed
        XCTAssertFalse(model.isVendorConsentGivenFor(vendorId: -99))
        XCTAssertFalse(model.isVendorConsentGivenFor(vendorId: -1))
        XCTAssertFalse(model.isVendorConsentGivenFor(vendorId: 0))
        XCTAssertFalse(model.isVendorConsentGivenFor(vendorId: 33))
        XCTAssertFalse(model.isVendorConsentGivenFor(vendorId: 34))
        XCTAssertFalse(model.isVendorConsentGivenFor(vendorId: 99))
    }

    func testVendorIdRange() {
        let model = self.parse("BOwOh-wOwOh-wABABBAAABAAAAACqADgAUACgAHgAPg")
        XCTAssertTrue(model.isVendorConsentGivenFor(vendorId: 15))
    }
}
