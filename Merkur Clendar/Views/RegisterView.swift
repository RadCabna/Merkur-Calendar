import SwiftUI
import PhotosUI
import AVFoundation

struct RegisterView: View {
    @Environment(AuthViewModel.self) private var authVM
    @Environment(\.dismiss) private var dismiss

    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var avatarImage: UIImage? = nil
    @State private var showPhotoPicker = false
    @State private var showSourceMenu = false
    @State private var showCamera = false
    @State private var showCameraPermissionAlert = false

    @State private var showErrors = false
    @State private var passwordMismatch = false
    @State private var usernameError = false
    @State private var passwordError = false

    private var avatarSize: CGFloat { screenHeight * 0.13 }

    var body: some View {
        ZStack {
            Image("appBG")
                .resizable()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, screenHeight * 0.025)
                    .padding(.top, screenHeight * 0.065)

                ScrollView(showsIndicators: false) {
                VStack(spacing: screenHeight * 0.025) {
                    avatarPicker
                        .padding(.top, screenHeight * 0.015)

                    VStack(spacing: screenHeight * 0.018) {
                        authField(icon: "person.fill", placeholder: "USERNAME",
                                  text: $username, isError: usernameError)
                        authField(icon: "lock.fill", placeholder: "PASSWORD",
                                  text: $password, isSecure: true, isError: passwordError)
                        authField(icon: "lock.fill", placeholder: "CONFIRM PASSWORD",
                                  text: $confirmPassword, isSecure: true,
                                  isError: passwordMismatch)

                        if passwordMismatch {
                            Text("Passwords do not match")
                                .font(.poppinsExtraLight(size: screenHeight * 0.014))
                                .foregroundStyle(.red.opacity(0.85))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, screenHeight * 0.02)
                        }
                    }

                    registerButton
                        .padding(.top, screenHeight * 0.01)
                }
                .padding(.horizontal, screenHeight * 0.025)
                .padding(.bottom, screenHeight * 0.06)
            }
            }
        }
        .confirmationDialog("Choose photo source", isPresented: $showSourceMenu, titleVisibility: .visible) {
            Button("Gallery") { showPhotoPicker = true }
            Button("Camera") { requestCameraAccess() }
            Button("Cancel", role: .cancel) {}
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhotoItem, matching: .images)
        .onChange(of: selectedPhotoItem) { _, item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self),
                   let img = UIImage(data: data) {
                    avatarImage = img
                }
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPickerView(image: $avatarImage)
                .ignoresSafeArea()
        }
        .alert("Camera Access", isPresented: $showCameraPermissionAlert) {
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please allow camera access in Settings to take a photo.")
        }
    }

    private func requestCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted { showCamera = true }
                    else { showCameraPermissionAlert = true }
                }
            }
        default:
            showCameraPermissionAlert = true
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            Button { dismiss() } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: screenHeight * 0.012)
                        .fill(Color(red: 0.04, green: 0.07, blue: 0.18))
                        .frame(width: screenHeight * 0.055, height: screenHeight * 0.044)
                    Text("←")
                        .font(.poppinsSemiBold(size: screenHeight * 0.024))
                        .foregroundStyle(Color("gold"))
                }
            }
            .buttonStyle(.plain)
            .goldGlowBorder(cornerRadius: screenHeight * 0.012)

            Spacer()

            Text("MERKUR CASINO\nEVENT CALENDAR")
                .font(.poppinsSemiBold(size: screenHeight * 0.022))
                .foregroundStyle(Color("gold"))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
            
            Image("appLogo")
                .resizable()
                .scaledToFit()
                .frame(height: screenHeight * 0.075)
        }
    }

    private var avatarPicker: some View {
        Button { showSourceMenu = true } label: {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if let img = avatarImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .padding(screenHeight * 0.025)
                            .foregroundStyle(Color("gold").opacity(0.5))
                    }
                }
                .frame(width: avatarSize, height: avatarSize)
                .background(Color(red: 0.04, green: 0.07, blue: 0.18))
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(Color("gold"), lineWidth: 3)
                }

                ZStack {
                    Circle()
                        .fill(Color(red: 0.06, green: 0.1, blue: 0.28))
                        .frame(width: screenHeight * 0.038, height: screenHeight * 0.038)
                    Image(systemName: "pencil")
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenHeight * 0.018)
                        .foregroundStyle(.white)
                }
                .overlay { Circle().stroke(Color("gold").opacity(0.6), lineWidth: 1.5) }
                .offset(x: -4, y: -4)
            }
        }
        .buttonStyle(.plain)
    }

    private var registerButton: some View {
        Button {
            showErrors = true
            usernameError = username.trimmingCharacters(in: .whitespaces).isEmpty
            passwordError = password.isEmpty
            passwordMismatch = password != confirmPassword && !confirmPassword.isEmpty

            guard !usernameError, !passwordError, password == confirmPassword else { return }

            let photoData = avatarImage?.jpegData(compressionQuality: 0.8)
            if authVM.register(username: username, password: password, photoData: photoData) {
                dismiss()
            }
        } label: {
                    Text("SIGN UP")
                .font(.poppinsSemiBold(size: screenHeight * 0.022))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: screenHeight * 0.072)
                .background(Color("gold"))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func authField(icon: String, placeholder: String, text: Binding<String>,
                           isSecure: Bool = false, isError: Bool = false) -> some View {
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
    RegisterView()
        .environment(AuthViewModel())
}
