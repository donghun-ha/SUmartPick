//
//  AddressItem.swift
//  SUmartPick
//
//  Created by aeong on 2/3/25.
//

import Foundation

struct AddressItem: Codable, Identifiable {
    var id: Int // Address_ID
    var userId: String // User_ID
    var address: String
    var addressDetail: String?
    var postalCode: String?
    var recipientName: String?
    var phone: String?
    var isDefault: Bool?

    enum CodingKeys: String, CodingKey {
        case id = "Address_ID"
        case userId = "User_ID"
        case address
        case addressDetail = "address_detail"
        case postalCode = "postal_code"
        case recipientName = "recipient_name"
        case phone
        case isDefault = "is_default"
    }
}
