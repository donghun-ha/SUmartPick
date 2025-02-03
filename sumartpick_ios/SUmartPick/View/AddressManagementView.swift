//
//  AddressManagementView.swift
//  SUmartPick
//
//  Created by aeong on 2/3/25.
//

import SwiftUI

struct AddressManagementView: View {
    @EnvironmentObject var authState: AuthenticationState
    @StateObject var viewModel = AddressViewModel()

    // 새 주소 추가 시트
    @State private var showCreateSheet = false
    // 주소 수정 시트
    @State private var showEditSheet = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.addresses) { addr in
                    VStack(alignment: .leading, spacing: 8) {
                        // 주소 정보(기본주소, 상세주소, 수취인 등)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(addr.address)
                                .font(.headline)
                            if let detail = addr.addressDetail, !detail.isEmpty {
                                Text(detail)
                                    .font(.subheadline)
                            }
                            if let recipient = addr.recipientName, !recipient.isEmpty {
                                Text("수취인: \(recipient)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            if addr.isDefault == true {
                                Text("기본 배송지")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                        }

                        // 수정 / 삭제 버튼
                        HStack {
                            Button("수정") {
                                // 수정 로직
                                viewModel.editingAddress = addr
                                showEditSheet = true
                            }
                            .buttonStyle(.bordered)

                            Button("삭제") {
                                Task {
                                    await viewModel.deleteAddress(addr.id, userID: addr.userId)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle("주소지 관리")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 우측 상단 + 버튼 → 새 주소 추가
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // 새 주소 시트 열기
                        viewModel.editingAddress = nil
                        showCreateSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .task {
                // 화면 최초 로드시 주소 목록 불러오기
                if let userID = authState.userIdentifier {
                    await viewModel.fetchAddresses(for: userID)
                }
            }
            .alert("오류 발생", isPresented: $viewModel.showErrorAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            // (1) 새 주소 등록 시트
            .sheet(isPresented: $showCreateSheet) {
                if let userID = authState.userIdentifier {
                    AddressEditSheet(
                        userID: userID,
                        viewModel: viewModel,
                        isPresented: $showCreateSheet,
                        isEditing: false
                    )
                }
            }
            // (2) 주소 수정 시트
            .sheet(isPresented: $showEditSheet) {
                if let editingAddr = viewModel.editingAddress {
                    AddressEditSheet(
                        userID: editingAddr.userId,
                        viewModel: viewModel,
                        isPresented: $showEditSheet,
                        isEditing: true,
                        addressItem: editingAddr
                    )
                }
            }
        }
    }
}
