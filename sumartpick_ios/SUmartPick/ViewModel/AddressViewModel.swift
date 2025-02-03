//
//  AddressViewModel.swift
//  SUmartPick
//
//  Created by aeong on 2/3/25.
//

import SwiftUI

@MainActor
class AddressViewModel: ObservableObject {
    @Published var addresses: [AddressItem] = []
    @Published var errorMessage = ""
    @Published var showErrorAlert = false

    // 새 주소 생성/수정용 임시 저장 프로퍼티
    @Published var editingAddress: AddressItem? = nil

    let baseURL = SUmartPickConfig.baseURL

    // 주소 목록 불러오기
    func fetchAddresses(for userID: String) async {
        guard let url = URL(string: "\(baseURL)/addresses/\(userID)") else { return }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            let decoder = JSONDecoder()
            let fetched = try decoder.decode([AddressItem].self, from: data)
            self.addresses = fetched
        } catch {
            self.errorMessage = error.localizedDescription
            self.showErrorAlert = true
        }
    }

    // 주소 추가
    func createAddress(_ newAddr: AddressItem) async {
        guard let url = URL(string: "\(baseURL)/addresses") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let encoder = JSONEncoder()
            let body = try encoder.encode(newAddr)
            request.httpBody = body

            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }

            // 성공 후 다시 목록 가져오기
            await self.fetchAddresses(for: newAddr.userId)
        } catch {
            self.errorMessage = error.localizedDescription
            self.showErrorAlert = true
        }
    }

    // 주소 수정
    func updateAddress(_ updatedAddr: AddressItem) async {
        guard let addressID = updatedAddr.id as Int?,
              let url = URL(string: "\(baseURL)/addresses/\(addressID)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let encoder = JSONEncoder()
            let body = try encoder.encode(updatedAddr)
            request.httpBody = body

            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }

            // 수정 후 다시 목록 가져오기
            await self.fetchAddresses(for: updatedAddr.userId)
        } catch {
            self.errorMessage = error.localizedDescription
            self.showErrorAlert = true
        }
    }

    // 주소 삭제
    func deleteAddress(_ addressID: Int, userID: String) async {
        guard let url = URL(string: "\(baseURL)/addresses/\(addressID)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            // 삭제 후 다시 목록 갱신
            await self.fetchAddresses(for: userID)
        } catch {
            self.errorMessage = error.localizedDescription
            self.showErrorAlert = true
        }
    }
}
