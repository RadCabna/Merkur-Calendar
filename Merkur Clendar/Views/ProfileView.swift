import SwiftUI
import PhotosUI
import AVFoundation

struct ProfileView: View {
    @Environment(AuthViewModel.self) private var authVM
    @Environment(EventsStore.self) private var eventsStore

    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var showPhotoPicker = false
    @State private var showSourceMenu = false
    @State private var showCamera = false
    @State private var showCameraPermissionAlert = false
    @State private var cameraImage: UIImage? = nil
    @State private var showEditProfile = false

    private var avatarSize: CGFloat { screenHeight * 0.115 }
    private var cornerRadius: CGFloat { screenHeight * 0.022 }
    private var cardPadding: CGFloat { screenHeight * 0.02 }

    private var profile: UserProfile { UserProfile(name: authVM.currentUser?.username ?? "USER", xp: 0) }

    private var cardBackground: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: Color(red: 0.03, green: 0.06, blue: 0.17), location: 0),
                .init(color: Color(red: 0.07, green: 0.14, blue: 0.33), location: 0.45),
                .init(color: Color(red: 0.04, green: 0.08, blue: 0.22), location: 0.75),
                .init(color: Color(red: 0.02, green: 0.05, blue: 0.15), location: 1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack {
            Image("appBG")
                .resizable()
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: screenHeight * 0.025) {
                    pageHeader
                    avatarRow
                    LevelCardView(profile: profile)
                    statsCard
                    quitButton
                }
                .padding(.horizontal, screenHeight * 0.02)
                .padding(.top, screenHeight * 0.015)
                .padding(.bottom, screenHeight * 0.16)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog("Choose photo source", isPresented: $showSourceMenu, titleVisibility: .visible) {
            Button("Gallery") {
                showPhotoPicker = true
            }
            Button("Camera") {
                requestCameraAccess()
            }
            Button("Cancel", role: .cancel) {}
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhotoItem, matching: .images)
        .onChange(of: selectedPhotoItem) { _, item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self) {
                    authVM.updatePhoto(data)
                }
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPickerView(image: $cameraImage)
                .ignoresSafeArea()
        }
        .onChange(of: cameraImage) { _, image in
            if let image, let data = image.jpegData(compressionQuality: 0.85) {
                authVM.updatePhoto(data)
            }
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

    private var pageHeader: some View {
        Text("Profile")
            .font(.poppinsSemiBold(size: screenHeight * 0.028))
            .foregroundStyle(Color("gold"))
            .frame(maxWidth: .infinity)
            .padding(.top, screenHeight * 0.01)
    }

    private var avatarRow: some View {
        HStack(spacing: screenHeight * 0.022) {
            Button { showSourceMenu = true } label: {
                ZStack(alignment: .bottomTrailing) {
                    Group {
                        if let data = authVM.currentUser?.photoData,
                           let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                        } else {
                            ZStack {
                                Color(red: 0.04, green: 0.07, blue: 0.18)
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(avatarSize * 0.22)
                                    .foregroundStyle(Color("gold").opacity(0.5))
                            }
                        }
                    }
                    .frame(width: avatarSize, height: avatarSize)
                    .clipShape(Circle())
                    .overlay { Circle().stroke(Color("gold"), lineWidth: 3) }

                    ZStack {
                        Circle()
                            .fill(Color(red: 0.06, green: 0.1, blue: 0.28))
                            .frame(width: avatarSize * 0.32, height: avatarSize * 0.32)
                        Image(systemName: "pencil")
                            .resizable()
                            .scaledToFit()
                            .frame(width: avatarSize * 0.14)
                            .foregroundStyle(.white)
                    }
                    .overlay { Circle().stroke(Color("gold").opacity(0.6), lineWidth: 1.5) }
                    .offset(x: -2, y: -2)
                }
            }
            .buttonStyle(.plain)

            HStack(spacing: screenHeight * 0.012) {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: screenHeight * 0.022)
                    .foregroundStyle(Color("gold").opacity(0.8))

                Text((authVM.currentUser?.username ?? "USER").uppercased())
                    .font(.poppinsSemiBold(size: screenHeight * 0.02))
                    .foregroundStyle(Color("gold"))

                Spacer()

                Button { showEditProfile = true } label: {
                    Image(systemName: "pencil")
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenHeight * 0.018)
                        .foregroundStyle(Color("gold"))
                        .padding(screenHeight * 0.012)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, screenHeight * 0.018)
            .frame(height: screenHeight * 0.062)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(red: 0.04, green: 0.07, blue: 0.18))
            .clipShape(Capsule())
            .goldBorder(cornerRadius: screenHeight * 0.031, lineWidth: 2)
            .sheet(isPresented: $showEditProfile) {
                EditProfileSheet()
                    .environment(authVM)
                    .presentationDetents([.fraction(0.55)])
                    .presentationBackground(Color(red: 0.04, green: 0.06, blue: 0.18))
            }

            Spacer()
        }
    }

    private var statsCard: some View {
        VStack(spacing: 0) {
            statRow(label: "TOTAL POINTS",      value: "\(profile.xp.formatted()) XP", isFirst: true)
            statDivider
            statRow(label: "EVENTS ATTENDED",   value: "\(eventsStore.events.count)")
            statDivider
            statRow(label: "TOURNAMENTS WON",   value: "0")
            statDivider
            statRow(label: "BONUSES RECEIVED",  value: "$0", isLast: true)
        }
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .goldBorder(cornerRadius: cornerRadius, lineWidth: 4)
    }

    @ViewBuilder
    private func statRow(label: String, value: String, isFirst: Bool = false, isLast: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.poppinsSemiBold(size: screenHeight * 0.015))
                .foregroundStyle(.white.opacity(0.8))
            Spacer()
            Text(value)
                .font(.poppinsSemiBold(size: screenHeight * 0.017))
                .foregroundStyle(Color("gold"))
        }
        .padding(.horizontal, cardPadding)
        .padding(.vertical, screenHeight * 0.016)
    }

    private var statDivider: some View {
        Rectangle()
            .fill(Color("gold").opacity(0.15))
            .frame(height: 1)
            .padding(.horizontal, cardPadding)
    }

    private var quitButton: some View {
        Button {
            authVM.logout()
        } label: {
            Text("QUIT")
                .font(.poppinsSemiBold(size: screenHeight * 0.026))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: screenHeight * 0.072)
                .background(Color("gold"))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ProfileView()
        .environment(AuthViewModel())
        .environment(EventsStore())
}
