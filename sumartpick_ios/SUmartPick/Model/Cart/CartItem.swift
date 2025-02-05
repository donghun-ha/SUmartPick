//
//  CartItem.swift
//  SUmartPick
//
//  Created by 이종남 on 2/3/25.
//

import RealmSwift

// ✅ 장바구니 모델
class CartItem: Object, Identifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var userId: String
    @Persisted var productId: Int
    @Persisted var productName: String
    @Persisted var productImage: String
    @Persisted var price: Double
    @Persisted var quantity: Int

    // 편리한 초기화
    convenience init(userId: String, productId: Int, productName: String, productImage: String, price: Double, quantity: Int) {
        self.init()
        self.userId = userId
        self.productId = productId
        self.productName = productName
        self.productImage = productImage
        self.price = price
        self.quantity = quantity
    }
}


