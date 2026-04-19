import SwiftUI

struct EditProfileSheet: View {
    @Environment(AuthViewModel.self) private var authVM
    @Environment(\.dismiss) private var dismiss

    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""

    @State private var usernameError = false
    @State private var passwordError = false
    @State private var confirmError = false
    @State private var mismatchError = false

    var body: some View {
        VStack(spacing: screenHeight * 0.025) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: screenHeight * 0.02, weight: .semibold))
                        .foregroundStyle(Color("gold"))
                        .frame(width: screenHeight * 0.042, height: screenHeight * 0.042)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                Spacer()

                Text("Edit Profile")
                    .font(.poppinsSemiBold(size: screenHeight * 0.024))
                    .foregroundStyle(Color("gold"))

                Spacer()

                Color.clear.frame(width: screenHeight * 0.042)
            }
            .padding(.top, screenHeight * 0.018)

            VStack(spacing: screenHeight * 0.016) {
                editField(icon: "person.fill",
                          placeholder: "USERNAME",
                          text: $username,
                          isError: usernameError)

                editField(icon: "lock.fill",
                          placeholder: "NEW PASSWORD",
                          text: $password,
                          isSecure: true,
                          isError: passwordError)

                editField(icon: "lock.fill",
                          placeholder: "CONFIRM PASSWORD",
                          text: $confirmPassword,
                          isSecure: true,
                          isError: confirmError)

                if mismatchError {
                    Text("Passwords do not match")
                        .font(.poppinsExtraLight(size: screenHeight * 0.014))
                        .foregroundStyle(.red.opacity(0.85))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, screenHeight * 0.02)
                }
            }

            Button {
                save()
            } label: {
                Text("SAVE")
                    .font(.poppinsSemiBold(size: screenHeight * 0.022))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: screenHeight * 0.068)
                    .background(Color("gold"))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.horizontal, screenHeight * 0.025)
        .onAppear {
            username = authVM.currentUser?.username ?? ""
        }
    }

    private func save() {
        usernameError = username.trimmingCharacters(in: .whitespaces).isEmpty
        passwordError = password.isEmpty
        confirmError = confirmPassword.isEmpty
        mismatchError = !password.isEmpty && password != confirmPassword

        guard !usernameError, !passwordError, !confirmError, !mismatchError else { return }

        authVM.updateProfile(username: username, password: password)
        dismiss()
    }

    @ViewBuilder
    private func editField(icon: String, placeholder: String,
                           text: Binding<String>, isSecure: Bool = false,
                           isError: Bool = false) -> some View {
        HStack(spacing: screenHeight * 0.016) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: screenHeight * 0.022, height: screenHeight * 0.022)
                .foregroundStyle(isError ? Color.red.opacity(0.8) : Color("gold").opacity(0.7))
                .padding(.leading, screenHeight * 0.022)

            if isSecure {
                SecureField("", text: text, prompt:
                    Text(placeholder)
                        .font(.poppinsSemiBold(size: screenHeight * 0.018))
                        .foregroundStyle(isError ? Color.red.opacity(0.6) : Color("gold").opacity(0.5))
                )
                .font(.poppinsSemiBold(size: screenHeight * 0.018))
                .foregroundStyle(Color("gold"))
                .tint(Color("gold"))
            } else {
                TextField("", text: text, prompt:
                    Text(placeholder)
                        .font(.poppinsSemiBold(size: screenHeight * 0.018))
                        .foregroundStyle(isError ? Color.red.opacity(0.6) : Color("gold").opacity(0.5))
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
        .overlay {
            Capsule()
                .strokeBorder(isError ? Color.red.opacity(0.85) : Color.clear, lineWidth: 1.5)
        }
        .goldGlowCapsuleBorder()
    }
}

#Preview {
    EditProfileSheet()
        .environment(AuthViewModel())
        .background(Color(red: 0.04, green: 0.06, blue: 0.18))
}
