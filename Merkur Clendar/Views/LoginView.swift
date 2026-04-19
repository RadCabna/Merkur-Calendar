import SwiftUI

struct LoginView: View {
    @Environment(AuthViewModel.self) private var authVM
    @State private var username = ""
    @State private var password = ""
    @State private var showError = false
    @State private var showRegister = false

    var body: some View {
        ZStack {
            Image("appBG")
                .resizable()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                appHeader
                    .padding(.horizontal, screenHeight * 0.025)
                    .padding(.top, screenHeight * 0.07)

                Spacer()

                VStack(spacing: screenHeight * 0.022) {
                    authField(icon: "person.fill", placeholder: "USERNAME", text: $username)
                    authField(icon: "lock.fill", placeholder: "PASSWORD", text: $password, isSecure: true)
                }
                .padding(.horizontal, screenHeight * 0.025)

                if showError {
                    Text("Invalid username or password")
                        .font(.poppinsExtraLight(size: screenHeight * 0.015))
                        .foregroundStyle(.red.opacity(0.85))
                        .padding(.top, screenHeight * 0.012)
                }

                Spacer()

                VStack(spacing: screenHeight * 0.018) {
                    Button {
                        if authVM.login(username: username, password: password) {
                            showError = false
                        } else {
                            showError = true
                        }
                    } label: {
                        Text("LOGIN")
                            .font(.poppinsSemiBold(size: screenHeight * 0.026))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: screenHeight * 0.072)
                            .background(Color("gold"))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)

                    Button {
                        showRegister = true
                    } label: {
                        Text("SIGN UP")
                            .font(.poppinsSemiBold(size: screenHeight * 0.018))
                            .foregroundStyle(Color("gold"))
                            .padding(.vertical, screenHeight * 0.01)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, screenHeight * 0.025)
                .padding(.bottom, screenHeight * 0.08)
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showRegister) {
            RegisterView()
                .environment(authVM)
        }
    }

    private var appHeader: some View {
        HStack(alignment: .top, spacing: screenHeight * 0.015) {
            Text("MERKUR CASINO\nEVENT CALENDAR")
                .font(.poppinsSemiBold(size: screenHeight * 0.026))
                .foregroundStyle(Color("gold"))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            Image("appLogo")
                .resizable()
                .scaledToFit()
                .frame(height: screenHeight * 0.085)
        }
    }

    @ViewBuilder
    private func authField(icon: String, placeholder: String, text: Binding<String>, isSecure: Bool = false) -> some View {
        HStack(spacing: screenHeight * 0.016) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: screenHeight * 0.022, height: screenHeight * 0.022)
                .foregroundStyle(Color("gold").opacity(0.7))
                .padding(.leading, screenHeight * 0.022)

            if isSecure {
                SecureField("", text: text, prompt:
                    Text(placeholder)
                        .font(.poppinsSemiBold(size: screenHeight * 0.018))
                        .foregroundStyle(Color("gold").opacity(0.5))
                )
                .font(.poppinsSemiBold(size: screenHeight * 0.018))
                .foregroundStyle(Color("gold"))
                .tint(Color("gold"))
            } else {
                TextField("", text: text, prompt:
                    Text(placeholder)
                        .font(.poppinsSemiBold(size: screenHeight * 0.018))
                        .foregroundStyle(Color("gold").opacity(0.5))
                )
                .font(.poppinsSemiBold(size: screenHeight * 0.018))
                .foregroundStyle(Color("gold"))
                .tint(Color("gold"))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            }
        }
        .frame(height: screenHeight * 0.065)
        .background(Color(red: 0.04, green: 0.07, blue: 0.18))
        .clipShape(Capsule())
        .goldGlowCapsuleBorder()
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
    .environment(AuthViewModel())
}
