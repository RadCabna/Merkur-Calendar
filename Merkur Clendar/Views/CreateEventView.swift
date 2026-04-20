import SwiftUI
import PhotosUI

struct CreateEventView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(EventsStore.self) private var eventsStore
    @State private var viewModel = CreateEventViewModel()

    private var fieldHeight: CGFloat { screenHeight * 0.058 }
    private var cornerRadius: CGFloat { screenHeight * 0.029 }
    private var sectionSpacing: CGFloat { screenHeight * 0.022 }

    private enum Field: Hashable { case name, location, prizePool, buyIn, maxPlayers, description }
    @FocusState private var focus: Field?

    var body: some View {
        ZStack {
            Image("appBG")
                .resizable()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView(showsIndicators: false) {
                    VStack(spacing: sectionSpacing) {
                        GoldInputField(placeholder: "Event Name", text: $viewModel.eventName,
                                       isError: viewModel.nameError,
                                       submitLabel: .next,
                                       onSubmit: { focus = .location })
                            .focused($focus, equals: .name)

                        HStack(spacing: screenHeight * 0.014) {
                            datePickerField(placeholder: "Date",
                                            value: viewModel.dateDisplayString,
                                            isError: viewModel.dateError,
                                            action: { viewModel.showDatePicker = true })
                            datePickerField(placeholder: "Time",
                                            value: viewModel.timeDisplayString,
                                            isError: viewModel.timeError,
                                            action: { viewModel.showTimePicker = true })
                        }

                        GoldInputField(placeholder: "Location", text: $viewModel.location,
                                       isError: viewModel.locationError,
                                       submitLabel: .done,
                                       onSubmit: { focus = nil })
                            .focused($focus, equals: .location)

                        eventTypeSection
                            .overlay(alignment: .bottom) {
                                if viewModel.categoryError {
                                    Text("Выберите тип события")
                                        .font(.poppinsExtraLight(size: screenHeight * 0.013))
                                        .foregroundStyle(.red.opacity(0.85))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .offset(y: screenHeight * 0.022)
                                }
                            }

                        prizeFreeRow

                        HStack(spacing: screenHeight * 0.014) {
                            GoldInputField(placeholder: "Buy In", text: $viewModel.buyIn, keyboardType: .decimalPad)
                                .focused($focus, equals: .buyIn)
                            GoldInputField(placeholder: "Players", text: $viewModel.maxPlayers, keyboardType: .numberPad)
                                .focused($focus, equals: .maxPlayers)
                        }

                        dressCodeSection

                        descriptionField

                        mediaSection

                        visibilitySection

                        saveButton
                            .padding(.top, screenHeight * 0.01)
                    }
                    .padding(.horizontal, screenHeight * 0.02)
                    .padding(.top, screenHeight * 0.022)
                    .padding(.bottom, screenHeight * 0.06)
                }
                .scrollDismissesKeyboard(.interactively)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") { focus = nil }
                            .font(.poppinsSemiBold(size: screenHeight * 0.018))
                            .foregroundStyle(Color("gold"))
                    }
                }
            }
        }
        .hideKeyboardOnTap()
        .sheet(isPresented: $viewModel.showDatePicker) {
            datePicker(components: .date, minDate: Calendar.current.startOfDay(for: Date())) { date in
                viewModel.eventDate = date
                viewModel.showDatePicker = false
            }
        }
        .sheet(isPresented: $viewModel.showTimePicker) {
            datePicker(components: .hourAndMinute, minDate: viewModel.isDateToday ? Date() : .distantPast) { date in
                viewModel.eventTime = date
                viewModel.showTimePicker = false
            }
        }
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: screenHeight * 0.012)
                        .fill(Color(red: 0.04, green: 0.07, blue: 0.18))
                        .goldGlowBorder(cornerRadius: screenHeight * 0.012)
                    Image(systemName: "chevron.left")
                        .font(.system(size: screenHeight * 0.018, weight: .semibold))
                        .foregroundStyle(Color("gold"))
                }
                .frame(width: screenHeight * 0.053, height: screenHeight * 0.053)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Create Event")
                .font(.poppinsSemiBold(size: screenHeight * 0.028))
                .foregroundStyle(Color("gold"))

            Spacer()

            Color.clear
                .frame(width: screenHeight * 0.053, height: screenHeight * 0.053)
        }
        .padding(.horizontal, screenHeight * 0.02)
        .padding(.vertical, screenHeight * 0.015)
    }

    @ViewBuilder
    private func datePickerField(placeholder: String, value: String, isError: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(value.isEmpty ? placeholder : value)
                    .font(.poppinsSemiBold(size: screenHeight * 0.018))
                    .foregroundStyle(
                        isError ? Color.red.opacity(0.7) :
                        (value.isEmpty ? Color("gold").opacity(0.5) : Color("gold"))
                    )
                    .padding(.horizontal, screenHeight * 0.02)
                Spacer()
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
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    private var eventTypeSection: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.014) {
            Text("Event Type")
                .font(.poppinsSemiBold(size: screenHeight * 0.02))
                .foregroundStyle(Color("gold"))

            HStack(spacing: screenHeight * 0.012) {
                ForEach(EventCategory.allCases, id: \.title) { cat in
                    eventTypeButton(cat)
                }
            }
        }
    }

    @ViewBuilder
    private func eventTypeButton(_ cat: EventCategory) -> some View {
        let isSelected = viewModel.category == cat
        let cr = screenHeight * 0.018
        Button {
            viewModel.category = isSelected ? nil : cat
        } label: {
            Image(cat.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: cr))
                .overlay {
                    if isSelected {
                        ZStack {
                            RoundedRectangle(cornerRadius: cr)
                                .strokeBorder(Color("gold").opacity(0.45), lineWidth: 10)
                                .blur(radius: 7)
                            RoundedRectangle(cornerRadius: cr)
                                .stroke(Color("gold").opacity(0.85), lineWidth: 1.5)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: cr))
                    }
                }
        }
        .buttonStyle(.plain)
    }

    private var prizeFreeRow: some View {
        HStack(spacing: screenHeight * 0.012) {
            GoldInputField(placeholder: "Prize Pool", text: $viewModel.prizePool,
                           keyboardType: .decimalPad, isError: viewModel.prizeError)
                .focused($focus, equals: .prizePool)
                .frame(maxWidth: .infinity)
                .opacity(viewModel.isFree ? 0.4 : 1.0)
                .disabled(viewModel.isFree)

            Text("Or")
                .font(.poppinsExtraLight(size: screenHeight * 0.016))
                .foregroundStyle(.white)

            Button { viewModel.isFree.toggle() } label: {
                HStack(spacing: screenHeight * 0.012) {
                    Text("Free")
                        .font(.poppinsExtraLight(size: screenHeight * 0.018))
                        .foregroundStyle(Color("gold"))
                    ZStack {
                        Circle()
                            .stroke(Color("gold").opacity(0.65), lineWidth: 3)
                            .frame(width: screenHeight * 0.028, height: screenHeight * 0.028)
                        if viewModel.isFree {
                            Circle()
                                .fill(Color("gold"))
                                .frame(width: screenHeight * 0.016, height: screenHeight * 0.016)
                        }
                    }
                }
                .padding(.horizontal, screenHeight * 0.018)
                .frame(height: fieldHeight)
                .background(Color(red: 0.04, green: 0.07, blue: 0.18))
                .clipShape(Capsule())
                .goldGlowCapsuleBorder()
            }
            .buttonStyle(.plain)
        }
    }

    private var dressCodeSection: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.014) {
            Text("Dress Code")
                .font(.poppinsSemiBold(size: screenHeight * 0.02))
                .foregroundStyle(Color("gold"))

            HStack(spacing: screenHeight * 0.01) {
                ForEach(DressCode.allCases, id: \.title) { code in
                    dressCodeChip(code)
                }
            }
            .padding(screenHeight * 0.01)
            .background {
                RoundedRectangle(cornerRadius: screenHeight * 0.028)
                    .fill(Color(red: 0.02, green: 0.03, blue: 0.09))
            }
            .overlay {
                RoundedRectangle(cornerRadius: screenHeight * 0.04)
                    .stroke(Color("gold").opacity(0.6), lineWidth: 2)
            }
        }
    }

    @ViewBuilder
    private func dressCodeChip(_ code: DressCode) -> some View {
        let isSelected = viewModel.dressCode == code
        let chipRadius = screenHeight * 0.022
        Button {
            viewModel.dressCode = viewModel.dressCode == code ? nil : code
        } label: {
            Text(code.title)
                .font(.poppinsSemiBold(size: screenHeight * 0.014))
                .foregroundStyle(isSelected ? Color.white : Color("gold").opacity(0.7))
                .frame(maxWidth: .infinity)
                .frame(height: screenHeight * 0.05)
                .background(Color(red: 0.05, green: 0.08, blue: 0.2))
                .clipShape(RoundedRectangle(cornerRadius: chipRadius))
                .overlay {
                    if isSelected {
                        ZStack {
                            RoundedRectangle(cornerRadius: chipRadius)
                                .strokeBorder(Color("gold").opacity(0.45), lineWidth: 10)
                                .blur(radius: 7)
                            RoundedRectangle(cornerRadius: chipRadius)
                                .stroke(Color("gold").opacity(0.85), lineWidth: 1.2)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: chipRadius))
                    } else {
                        RoundedRectangle(cornerRadius: chipRadius)
                            .stroke(Color("gold").opacity(0.85), lineWidth: 1.2)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    private var descriptionField: some View {
        ZStack(alignment: .topLeading) {
            if viewModel.eventDescription.isEmpty {
                Text("Description")
                    .font(.poppinsSemiBold(size: screenHeight * 0.018))
                    .foregroundStyle(Color("gold").opacity(0.5))
                    .padding(.horizontal, screenHeight * 0.02)
                    .padding(.top, screenHeight * 0.016)
                    .allowsHitTesting(false)
            }
            TextEditor(text: $viewModel.eventDescription)
                .font(.poppinsSemiBold(size: screenHeight * 0.018))
                .foregroundStyle(Color("gold"))
                .tint(Color("gold"))
                .scrollContentBackground(.hidden)
                .focused($focus, equals: .description)
                .padding(.horizontal, screenHeight * 0.012)
                .padding(.vertical, screenHeight * 0.008)
        }
        .frame(height: screenHeight * 0.15)
        .background(Color(red: 0.04, green: 0.07, blue: 0.18))
        .clipShape(RoundedRectangle(cornerRadius: screenHeight * 0.022))
        .goldGlowBorder(cornerRadius: screenHeight * 0.022)
    }

    private var mediaSection: some View {
        HStack(spacing: screenHeight * 0.014) {
            mediaThumbnailOrUpload
                .frame(maxWidth: .infinity)
                .frame(height: screenHeight * 0.11)
                .background(Color(red: 0.04, green: 0.07, blue: 0.18))
                .clipShape(RoundedRectangle(cornerRadius: screenHeight * 0.022))
                .goldGlowBorder(cornerRadius: screenHeight * 0.022)
                .onTapGesture { viewModel.showPhotoPicker = true }

            addMediaButton
                .frame(width: screenHeight * 0.13)
                .frame(height: screenHeight * 0.11)
                .background(Color(red: 0.04, green: 0.07, blue: 0.18))
                .clipShape(RoundedRectangle(cornerRadius: screenHeight * 0.022))
                .goldGlowBorder(cornerRadius: screenHeight * 0.022)
                .onTapGesture { viewModel.showPhotoPicker = true }
        }
        .photosPicker(
            isPresented: $viewModel.showPhotoPicker,
            selection: $viewModel.selectedPhotoItem,
            matching: .images,
            photoLibrary: .shared()
        )
        .onChange(of: viewModel.selectedPhotoItem) { _, item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    viewModel.selectedImage = uiImage
                }
            }
        }
    }

    @ViewBuilder
    private var mediaThumbnailOrUpload: some View {
        if let image = viewModel.selectedImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .clipped()
        } else {
            VStack(spacing: screenHeight * 0.008) {
                Image(systemName: "icloud.and.arrow.up")
                    .resizable()
                    .scaledToFit()
                    .frame(height: screenHeight * 0.034)
                    .foregroundStyle(Color("gold"))
                Text("Upload banner or images")
                    .font(.poppinsExtraLight(size: screenHeight * 0.013))
                    .foregroundStyle(Color("gold"))
                    .multilineTextAlignment(.center)
                Text("JPG, PNG up to 10MB")
                    .font(.poppinsExtraLight(size: screenHeight * 0.011))
                    .foregroundStyle(Color("gold").opacity(0.5))
            }
        }
    }

    private var addMediaButton: some View {
        VStack(spacing: screenHeight * 0.008) {
            Image(systemName: viewModel.selectedImage == nil ? "plus" : "photo.badge.checkmark")
                .font(.system(size: screenHeight * 0.032, weight: .semibold))
                .foregroundStyle(Color("gold"))
            Text("Add")
                .font(.poppinsSemiBold(size: screenHeight * 0.018))
                .foregroundStyle(Color("gold"))
        }
    }

    private var visibilitySection: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.014) {
            Text("Visibility")
                .font(.poppinsSemiBold(size: screenHeight * 0.02))
                .foregroundStyle(Color("gold"))

            HStack(spacing: screenHeight * 0.01) {
                ForEach(EventVisibility.allCases, id: \.title) { vis in
                    visibilityChip(vis)
                }
            }
            .padding(screenHeight * 0.01)
            .background {
                RoundedRectangle(cornerRadius: screenHeight * 0.028)
                    .fill(Color(red: 0.02, green: 0.03, blue: 0.09))
            }
            .overlay {
                RoundedRectangle(cornerRadius: screenHeight * 0.06)
                    .stroke(Color("gold").opacity(0.6), lineWidth: 1)
            }
        }
    }

    @ViewBuilder
    private func visibilityChip(_ vis: EventVisibility) -> some View {
        let isSelected = viewModel.visibility == vis
        let chipRadius = screenHeight * 0.022
        Button {
            viewModel.visibility = vis
        } label: {
            Text(vis.title)
                .font(.poppinsSemiBold(size: screenHeight * 0.013))
                .foregroundStyle(isSelected ? Color.white : Color("gold").opacity(0.7))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
                .frame(height: screenHeight * 0.05)
                .background(Color(red: 0.05, green: 0.08, blue: 0.2))
                .clipShape(RoundedRectangle(cornerRadius: chipRadius))
                .overlay {
                    if isSelected {
                        ZStack {
                            RoundedRectangle(cornerRadius: chipRadius)
                                .strokeBorder(Color("gold").opacity(0.45), lineWidth: 10)
                                .blur(radius: 7)
                            RoundedRectangle(cornerRadius: chipRadius)
                                .stroke(Color("gold").opacity(0.85), lineWidth: 1.2)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: chipRadius))
                    } else {
                        RoundedRectangle(cornerRadius: chipRadius)
                            .stroke(Color("gold").opacity(0.85), lineWidth: 1.2)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    private var saveButton: some View {
        Button {
            if viewModel.isFormValid {
                viewModel.save(to: eventsStore)
                dismiss()
            } else {
                viewModel.showErrors = true
            }
        } label: {
            Text("SAVE")
                .font(.poppinsSemiBold(size: screenHeight * 0.024))
                .foregroundStyle(viewModel.isFormValid ? Color.black : Color.black.opacity(0.4))
                .frame(maxWidth: .infinity)
                .frame(height: screenHeight * 0.072)
                .background(viewModel.isFormValid ? Color("gold") : Color("gold").opacity(0.35))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func datePicker(components: DatePickerComponents, minDate: Date = Date(), onConfirm: @escaping (Date) -> Void) -> some View {
        ZStack {
            Color(red: 0.04, green: 0.07, blue: 0.18).ignoresSafeArea()
            VStack(spacing: screenHeight * 0.025) {
                DatePicker("", selection: $viewModel.pickerDate, in: minDate..., displayedComponents: components)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .tint(Color("gold"))
                    .colorScheme(.dark)
                Button {
                    onConfirm(viewModel.pickerDate)
                } label: {
                    Text("Done")
                        .font(.poppinsSemiBold(size: screenHeight * 0.02))
                        .foregroundStyle(Color.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: screenHeight * 0.062)
                        .background(Color("gold"))
                        .clipShape(Capsule())
                        .padding(.horizontal, screenHeight * 0.04)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, screenHeight * 0.03)
        }
        .presentationDetents([.height(screenHeight * 0.38)])
        .presentationBackground(Color(red: 0.04, green: 0.07, blue: 0.18))
    }
}

#Preview {
    CreateEventView()
}
