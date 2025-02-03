//
//  AddressEditSheet.swift
//  SUmartPick
//
//  Created by aeong on 2/3/25.
//

import SwiftUI

struct AddressEditSheet: View {
    let userID: String
    @ObservedObject var viewModel: AddressViewModel
    @Binding var isPresented: Bool

    let isEditing: Bool
    @State var addressItem: AddressItem

    init(userID: String,
         viewModel: AddressViewModel,
         isPresented: Binding<Bool>,
         isEditing: Bool,
         addressItem: AddressItem? = nil)
    {
        self.userID = userID
        self.viewModel = viewModel
        self._isPresented = isPresented
        self.isEditing = isEditing
        // addressItem이 있으면 편집 모드, 없으면 새로 생성
        if let addressItem = addressItem {
            self._addressItem = State(initialValue: addressItem)
        } else {
            // 새 주소 초기화
            self._addressItem = State(initialValue: AddressItem(
                id: 0,
                userId: userID,
                address: "",
                addressDetail: nil,
                postalCode: nil,
                recipientName: nil,
                phone: nil,
                isDefault: false
            ))
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("주소")) {
                    TextField("주소", text: $addressItem.address)

                    // 상세주소 (Optional) → custom binding
                    TextField("상세주소",
                              text: Binding<String>(
                                  get: {
                                      addressItem.addressDetail ?? ""
                                  },
                                  set: { newVal in
                                      addressItem.addressDetail = newVal.isEmpty ? nil : newVal
                                  }
                              ))

                    // 우편번호 (Optional) → custom binding
                    TextField("우편번호",
                              text: Binding<String>(
                                  get: {
                                      addressItem.postalCode ?? ""
                                  },
                                  set: { newVal in
                                      addressItem.postalCode = newVal.isEmpty ? nil : newVal
                                  }
                              ))
                }
                Section(header: Text("수취인 정보")) {
                    // 수취인명 (Optional)
                    TextField("받는 분 성함",
                              text: Binding<String>(
                                  get: {
                                      addressItem.recipientName ?? ""
                                  },
                                  set: { newVal in
                                      addressItem.recipientName = newVal.isEmpty ? nil : newVal
                                  }
                              ))

                    // 연락처 (Optional)
                    TextField("연락처",
                              text: Binding<String>(
                                  get: {
                                      addressItem.phone ?? ""
                                  },
                                  set: { newVal in
                                      addressItem.phone = newVal.isEmpty ? nil : newVal
                                  }
                              ))
                }

                Toggle("기본 배송지", isOn: Binding<Bool>(
                    get: { addressItem.isDefault ?? false },
                    set: { addressItem.isDefault = $0 }
                ))
            }
            .navigationTitle(isEditing ? "주소 수정" : "주소 추가")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        Task {
                            if isEditing {
                                // 수정 호출
                                await viewModel.updateAddress(addressItem)
                            } else {
                                // 등록 호출
                                await viewModel.createAddress(addressItem)
                            }
                            isPresented = false
                        }
                    }
                }
            }
        }
    }
}
