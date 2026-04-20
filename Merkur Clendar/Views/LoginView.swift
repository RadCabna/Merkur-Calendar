import SwiftUI

struct LoginView: View {
    @Environment(AuthViewModel.self) private var authVM
    @State private var username = ""
    @State private var password = ""
    @State private var showError = false

    private enum Field: Hashable { case username, password }
    @FocusState private var focus: Field?

    var body: some View {
        ZStack {
            Image("appBG")
                .resizable()
                .ignoresSafeArea()
                .hideKeyboardOnTap()

            VStack(spacing: 0) {
                appHeader
                    .padding(.horizontal, screenHeight * 0.025)
                    .padding(.top, screenHeight * 0.07)

                Spacer()

                VStack(spacing: screenHeight * 0.022) {
                    authField(icon: "person.fill", placeholder: "USERNAME", text: $username, field: .username)
                        .submitLabel(.next)
                        .onSubmit { focus = .password }
                    authField(icon: "lock.fill", placeholder: "PASSWORD", text: $password, isSecure: true, field: .password)
                        .submitLabel(.done)
                        .onSubmit { attemptLogin() }
                }
                .padding(.horizontal, screenHeight * 0.025)

                if showError {
                    Text("Invalid username or password")
                        .font(.poppinsExtraLight(size: screenHeight * 0.015))
                        .foregroundStyle(.red.opacity(0.85))
                        .padding(.top, screenHeight * 0.012)
                }

                Spacer()

                Button {
                    attemptLogin()
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
                .padding(.horizontal, screenHeight * 0.025)
                .padding(.bottom, screenHeight * 0.08)
            }
        }
        .navigationBarHidden(true)
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

    private func attemptLogin() {
        focus = nil
        if authVM.login(username: username, password: password) {
            showError = false
        } else {
            showError = true
        }
    }

    @ViewBuilder
    private func authField(icon: String, placeholder: String, text: Binding<String>,
                           isSecure: Bool = false, field: Field) -> some View {
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
                .focused($focus, equals: field)
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
                .focused($focus, equals: field)
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
