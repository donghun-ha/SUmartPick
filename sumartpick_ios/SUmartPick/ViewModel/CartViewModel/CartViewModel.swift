//
//  CartViewModel.swift
//  SUmartPick
//
//  Created by 이종남 on 2/3/25.
//

import Foundation
import RealmSwift

class CartViewModel: ObservableObject {
    @Published var cartItems: [CartItem] = []

    //  항상 새로운 Realm 인스턴스를 가져와서 Frozen Realm 오류 방지
    private func getRealm() -> Realm {
        return try! Realm()
    }

    init() {
        loadCartItems()
    }

    //  장바구니 항목 불러오기
    func loadCartItems() {
        let realm = getRealm()
        cartItems = Array(realm.objects(CartItem.self))
    }

    //  장바구니에 상품 추가 (로컬 + 서버 동기화)
    func addToCart(userId: String, product: Product, quantity: Int) {
        let realm = getRealm()

        if let existingItem = realm.objects(CartItem.self)
            .filter("userId == %@ AND productId == %@", userId, product.productID)
            .first {
            try! realm.write {
                existingItem.quantity += quantity // 수량 증가
            }
        } else {
            let newItem = CartItem(
                userId: userId,
                productId: product.productID,
                productName: product.name,
                productImage: product.previewImage,
                price: product.price,
                quantity: quantity
            )
            try! realm.write {
                realm.add(newItem) // 새로운 항목 추가
            }
        }

        loadCartItems()  // ✅ UI 업데이트
        syncAddToServer(userId: userId, product: product, quantity: quantity) // 서버와 동기화
    }
    
    func updateQuantity(item: CartItem, newQuantity: Int) {
        guard newQuantity >= 1 else { return } // ❗️ 수량이 1 미만이면 업데이트 중단

        DispatchQueue.main.async {
            let realm = self.getRealm()
            if let itemToUpdate = realm.objects(CartItem.self)
                .filter("userId == %@ AND productId == %@", item.userId, item.productId)
                .first, !itemToUpdate.isInvalidated {  // ✅ 유효성 검사 추가
                do {
                    try realm.write {
                        itemToUpdate.quantity = newQuantity
                    }
                    self.loadCartItems()
                    self.syncUpdateQuantityToServer(userId: item.userId, productId: item.productId, quantity: newQuantity)
                } catch {
                    print("❌ Realm 업데이트 오류: \(error.localizedDescription)")
                }
            }
        }
    }

    
    //  장바구니에서 상품 삭제 (로컬 + 서버 동기화)
    func removeFromCart(userId: String, productId: Int) {
        DispatchQueue.main.async {
            let realm = self.getRealm()
            if let itemToRemove = realm.objects(CartItem.self)
                .filter("userId == %@ AND productId == %@", userId, productId)
                .first, !itemToRemove.isInvalidated {  // ✅ 유효성 검사 강화
                do {
                    try realm.write {
                        realm.delete(itemToRemove)
                    }
                    self.loadCartItems()
                    self.syncRemoveFromServer(userId: userId, productId: productId)
                } catch {
                    print("❌ Realm 삭제 오류: \(error.localizedDescription)")
                }
            }
        }
    }


    // 서버로 추가 요청 보내기
    private func syncAddToServer(userId: String, product: Product, quantity: Int) {
        guard let url = URL(string: "https://fastapi.sumartpick.shop/cart/add") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "user_id": userId,
            "product_id": product.productID,
            "qty": quantity
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ 서버 동기화 실패: \(error.localizedDescription)")
                return
            }
            print("✅ 서버에 성공적으로 추가됨!")
        }.resume()
    }

    //  서버로 수량 수정 요청 보내기
    private func syncUpdateQuantityToServer(userId: String, productId: Int, quantity: Int) {
        guard let url = URL(string: "https://fastapi.sumartpick.shop/cart/update") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "user_id": userId,
            "product_id": productId,
            "qty": quantity
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ 서버 수량 업데이트 실패: \(error.localizedDescription)")
                return
            }
            print("✅ 서버에 수량 성공적으로 업데이트됨!")
        }.resume()
    }


    //  서버에서 상품 삭제 요청 보내기
    private func syncRemoveFromServer(userId: String, productId: Int) {
        guard let url = URL(string: "https://fastapi.sumartpick.shop/cart/delete/\(userId)/\(productId)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ 서버 삭제 실패: \(error.localizedDescription)")
                return
            }
            print("✅ 서버에서 성공적으로 삭제됨!")
        }.resume()
    }

    //  장바구니 전체를 서버와 동기화
    func syncCartWithServer() {
        for item in cartItems {
            syncAddToServer(userId: item.userId, product: Product(
                productID: item.productId,
                name: item.productName,
                previewImage: item.productImage,
                price: item.price,
                detail: nil,
                category: ""
            ), quantity: item.quantity)
        }
    }
}
