//
//  EasyLoginAccount.swift
//  SUmartPick
//
//  Created by aeong on 1/14/25.
// Realm에 저장할 간편 로그인 계정 Model

import RealmSwift

class EasyLoginAccount: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var email: String
    @Persisted var fullName: String
}
s
