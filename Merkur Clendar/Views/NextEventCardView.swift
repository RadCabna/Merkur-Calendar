import SwiftUI

struct NextEventCardView: View {
    let event: AppEvent
    @Environment(EventsStore.self) private var eventsStore

    private var cornerRadius: CGFloat { screenHeight * 0.022 }
    private var cardHeight: CGFloat { screenHeight * 0.195 }

    var body: some View {
        HStack(spacing: 0) {
            leftColumn
                .frame(width: screenHeight * 0.105)

            Rectangle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 1)
                .padding(.vertical, screenHeight * 0.018)

            rightColumn
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 0)
        }
        .frame(height: cardHeight)
        .background {
            ZStack {
                backgroundImage
                LinearGradient(
                    stops: [
                        .init(color: Color(red: 0.03, green: 0.05, blue: 0.15).opacity(0.97), location: 0),
                        .init(color: Color(red: 0.03, green: 0.05, blue: 0.15).opacity(0.75), location: 0.45),
                        .init(color: Color.clear, location: 1)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
            .allowsHitTesting(false)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .goldBorder(cornerRadius: cornerRadius, lineWidth: 4)
    }

    @ViewBuilder
    private var backgroundImage: some View {
        if let data = event.customImageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(height: cardHeight)
                .clipped()
        } else {
            Image(event.eventType.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: cardHeight)
                .clipped()
        }
    }

    private var leftColumn: some View {
        VStack(spacing: screenHeight * 0.005) {
            Image("calendarImage")
                .resizable()
                .scaledToFit()
                .frame(height: screenHeight * 0.038)

            Text("\(event.day)")
                .font(.poppinsSemiBold(size: screenHeight * 0.044))
                .foregroundStyle(Color("gold"))

            Text(event.month)
                .font(.poppinsSemiBold(size: screenHeight * 0.016))
                .foregroundStyle(.white)

            Text(event.weekday)
                .font(.poppinsExtraLight(size: screenHeight * 0.012))
                .foregroundStyle(.white.opacity(0.8))

            HStack(spacing: 3) {
                Image(systemName: "clock")
                    .font(.system(size: screenHeight * 0.013))
                    .foregroundStyle(.white.opacity(0.8))
                Text(event.time)
                    .font(.poppinsExtraLight(size: screenHeight * 0.013))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .padding(.vertical, screenHeight * 0.018)
    }

    private var rightColumn: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.009) {
            Text(event.eventType.rawValue)
                .font(.poppinsSemiBold(size: screenHeight * 0.013))
                .foregroundStyle(.white)
                .padding(.horizontal, screenHeight * 0.012)
                .padding(.vertical, screenHeight * 0.005)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.white, lineWidth: 1)
                }

            Text(event.title)
                .font(.poppinsSemiBold(size: screenHeight * 0.022))
                .foregroundStyle(.white)
                .lineLimit(2)

            HStack(spacing: 4) {
                Image("geoIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(height: screenHeight * 0.016)
                Text(event.location)
                    .font(.poppinsSemiBold(size: screenHeight * 0.013))
                    .foregroundStyle(Color("gold"))
                    .lineLimit(2)
            }

            HStack(alignment: .bottom, spacing: screenHeight * 0.01) {
                VStack(alignment: .leading, spacing: 1) {
                    Text("-Prize Pool")
                        .font(.poppinsExtraLight(size: screenHeight * 0.012))
                        .foregroundStyle(.white.opacity(0.7))
                    Text(event.prizePool)
                        .font(.poppinsSemiBold(size: screenHeight * 0.016))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }

                Spacer(minLength: 4)

                let registered = eventsStore.isRegistered(event.id)
                Button { eventsStore.toggleRegistration(for: event.id) } label: {
                    HStack(spacing: 4) {
                        if registered {
                            Image(systemName: "clock")
                                .font(.system(size: screenHeight * 0.015, weight: .semibold))
                            Text("WAITING LIST")
                        } else {
                            Text("REGISTER")
                            Text("→")
                        }
                    }
                    .font(.poppinsSemiBold(size: screenHeight * 0.014))
                    .foregroundStyle(registered ? Color("gold") : .black)
                    .padding(.horizontal, screenHeight * 0.014)
                    .frame(height: screenHeight * 0.042)
                    .background(registered ? Color(red: 0.04, green: 0.07, blue: 0.18) : Color("gold"))
                    .clipShape(RoundedRectangle(cornerRadius: screenHeight * 0.021))
                    .overlay {
                        if registered {
                            RoundedRectangle(cornerRadius: screenHeight * 0.021)
                                .stroke(Color("gold"), lineWidth: 1.5)
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: registered)
                }
                .buttonStyle(.plain)
                .fixedSize()
            }
        }
        .padding(.leading, screenHeight * 0.014)
        .padding(.trailing, screenHeight * 0.012)
        .padding(.vertical, screenHeight * 0.016)
    }
}

#Preview {
    let comps = DateComponents(year: 2026, month: 5, day: 24, hour: 20, minute: 0)
    let date = Calendar.current.date(from: comps) ?? Date()
    ZStack {
        Image("appBG").resizable().ignoresSafeArea()
        NextEventCardView(event: AppEvent(
            date: date,
            eventType: .tournament,
            title: "High Roller Night",
            location: "GRAND POKER ROOM",
            prizePool: "50,000"
        ))
        .padding()
    }
}
