//
//  AddressManagementView.swift
//  SUmartPick
//
//  Created by aeong on 2/5/25.
//

import SwiftUI

struct AddressManagementView: View {
    @EnvironmentObject var authState: AuthenticationState
    @StateObject private var viewModel = AddressManagementViewModel()

    var body: some View {
        VStack(spacing: 16) {
            Text("주소지 관리")
                .font(.title)
                .padding(.top, 32)

            // 주소 입력 필드 (초기값은 현재 사용자 주소)
            TextField("주소 입력", text: $viewModel.address)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            Button {
                Task {
                    await viewModel.updateAddress()
                    // 업데이트 성공 시 AuthenticationState의 주소도 갱신
                    authState.userAddress = viewModel.address
                }
            } label: {
                Text("저장")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)

            Spacer()
        }
        .alert("오류 발생", isPresented: $viewModel.showErrorAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .onAppear {
            // 화면 로드 시 현재 주소값을 ViewModel에 반영
            viewModel.address = authState.userAddress ?? ""
        }
    }
}
