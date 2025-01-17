//
//  EasyLoginAccount.swift
//  SUmartPick
//
//  Created by aeong on 1/14/25.
//

import RealmSwift

class EasyLoginAccount: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var email: String
    @Persisted var fullName: String
}
