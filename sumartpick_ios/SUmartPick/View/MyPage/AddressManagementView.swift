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
    @State private var showSuccessAlert = false // 성공 알림 상태 추가
    @Environment(\.dismiss) private var dismiss // 현재 뷰 닫기 위한 dismiss

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
                    // userID가 없으면 에러 처리
                    guard let userID = authState.userIdentifier else {
                        viewModel.errorMessage = "사용자 정보가 없습니다."
                        viewModel.showErrorAlert = true
                        return
                    }
                    // 로딩 상태 시작
                    viewModel.isLoading = true
                    await viewModel.updateAddress(userID: userID)
                    // 로딩 상태 종료
                    viewModel.isLoading = false
                    // 업데이트 성공 시 AuthenticationState의 주소 갱신 후 성공 알림 표시
                    authState.userAddress = viewModel.address
                    showSuccessAlert = true
                }
            } label: {
                // 로딩 중이면 ProgressView, 아니면 "저장" 텍스트 표시
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(maxWidth: .infinity)
                } else {
                    Text("저장")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .disabled(viewModel.isLoading) // 로딩 중에는 버튼 비활성화

            Spacer()
        }
        // 에러 발생 시 Alert 표시
        .alert("오류 발생", isPresented: $viewModel.showErrorAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        // 주소 업데이트 성공 시 Alert 표시
        .alert("주소가 업데이트되었습니다.", isPresented: $showSuccessAlert) {
            Button("확인", role: .cancel) {
                dismiss() // 확인 버튼 누르면 현재 뷰 닫음 (뒤로 이동)
            }
        }
        .onAppear {
            // 화면 로드 시 현재 주소값을 ViewModel에 반영
            viewModel.address = authState.userAddress ?? ""
        }
    }
}
