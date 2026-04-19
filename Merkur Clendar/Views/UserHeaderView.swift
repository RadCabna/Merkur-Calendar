import SwiftUI

struct UserHeaderView: View {
    let profile: UserProfile
    var username: String? = nil
    var photoData: Data? = nil

    private var avatarSize: CGFloat { screenHeight * 0.075 }

    private var displayName: String {
        if let u = username, !u.isEmpty { return u.uppercased() }
        return profile.name
    }

    var body: some View {
        HStack(spacing: screenHeight * 0.018) {
            avatarView

            VStack(alignment: .leading, spacing: screenHeight * 0.004) {
                Text("Welcome back,")
                    .font(.poppinsSemiBold(size: screenHeight * 0.018))
                    .foregroundStyle(.white)
                Text(displayName)
                    .font(.poppinsSemiBold(size: screenHeight * 0.036))
                    .foregroundStyle(Color("gold"))
            }

            Spacer()
        }
    }

    @ViewBuilder
    private var avatarView: some View {
        ZStack {
            if let data = photoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Circle()
                    .fill(Color.white.opacity(0.1))
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(avatarSize * 0.22)
                    .foregroundStyle(.white.opacity(0.55))
            }
        }
        .frame(width: avatarSize, height: avatarSize)
        .clipShape(Circle())
        .overlay {
            Circle().stroke(LinearGradient.goldBorder, lineWidth: 3)
        }
    }
}

#Preview {
    ZStack {
        Image("appBG").resizable().ignoresSafeArea()
        UserHeaderView(profile: UserProfile(name: "ALEX", xp: 0), username: "ALEX")
            .padding()
    }
}
