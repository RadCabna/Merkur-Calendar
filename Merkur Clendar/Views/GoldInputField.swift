import SwiftUI

struct GoldInputField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isError: Bool = false
    var submitLabel: SubmitLabel = .done
    var onSubmit: (() -> Void)? = nil

    private var cornerRadius: CGFloat { screenHeight * 0.029 }
    private var fieldHeight: CGFloat { screenHeight * 0.058 }

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(.poppinsSemiBold(size: screenHeight * 0.018))
                    .foregroundStyle(isError ? Color.red.opacity(0.7) : Color("gold").opacity(0.5))
                    .padding(.horizontal, screenHeight * 0.02)
                    .allowsHitTesting(false)
            }
            TextField("", text: $text)
                .font(.poppinsSemiBold(size: screenHeight * 0.018))
                .foregroundStyle(Color("gold"))
                .tint(Color("gold"))
                .keyboardType(keyboardType)
                .submitLabel(submitLabel)
                .onSubmit { onSubmit?() }
                .padding(.horizontal, screenHeight * 0.02)
        }
        .frame(height: fieldHeight)
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
    @Previewable @State var text = ""
    ZStack {
        Image("appBG").resizable().ignoresSafeArea()
        VStack(spacing: 16) {
            GoldInputField(placeholder: "Event Name", text: $text)
            GoldInputField(placeholder: "Location", text: .constant("Grand Poker Room"))
        }
        .padding()
    }
}
