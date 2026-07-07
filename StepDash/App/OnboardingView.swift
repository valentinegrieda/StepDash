import SwiftUI
import SwiftData


enum Gender {
    static let male = "male"
    static let female = "female"

    /// All available options, in display order.
    static let allCases: [String] = [male, female]

    static func title(for value: String) -> String {
        value.capitalized
    }

    static func symbol(for value: String) -> String {
        value == male ? "figure.stand" : "figure.stand.dress"
    }
}




// MARK: - Flow container

struct OnboardingView: View {
    @Environment(\.modelContext) var context

    @State var name = ""
    @State var gender: String = Gender.male
    @State var heightCm = 160
    public var factor: Double {
        gender == Gender.male ? 0.415 : 0.413
    }
    @State var stepLength: Double = 0
    @State private var didFinish = false   // triggers navigation to GameView

    var nameValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ZStack {
            ScrollingBackground(imageName: "bg")
                .ignoresSafeArea()
            // Soft scrim so the logo and panels stay legible over the art.
            Pixel.ink.opacity(0.18).ignoresSafeArea()

            VStack(spacing: 20) {
                Image("StepDashLogo")
                    .resizable()
                    .interpolation(.none) // keep pixel art crisp
                    .scaledToFit()
                    .frame(maxHeight: 110)
                    .padding(.top, 12)

                ProfileSetup(
                    name: $name,
                    gender: $gender,
                    heightCm: $heightCm,
                    onStart: submitLog   // ProfileSetup just calls back into OnboardingView
                )

                Spacer()
            }
            .padding(20)
        }
        .fullScreenCover(isPresented: $didFinish) {
            GameContainerView(name: name, stepLength: stepLength)
        }
    }

    func finish() {
        didFinish = true
    }
}

// MARK: - Profile setup

struct ProfileSetup: View {
    @Binding var name: String
    @Binding var gender: String
    @Binding var heightCm: Int
    var onStart: () -> Void

    private var nameValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 18) {
            Text("CREATE YOUR COURIER")
                .font(Pixel.font(14, weight: .heavy))
                .foregroundStyle(Pixel.ink)

            // Name field
            FieldLabel("NAME") {
                TextField("Max 6 characters", text: $name)
                    .font(Pixel.font(16, weight: .bold))
                    .textInputAutocapitalization(.characters)
                    .padding(12)
                    .background(Rectangle().fill(.white)
                        .overlay(Rectangle().strokeBorder(Pixel.ink, lineWidth: 3)))
            }

            
            FieldLabel("GENDER") {
                HStack(spacing: 12) {
                    ForEach(Gender.allCases, id: \.self) { option in
                        Button { gender = option } label: {
                            HStack(spacing: 8) {
                                Image(systemName: Gender.symbol(for: option))
                                Text(Gender.title(for: option))
                                    .font(Pixel.font(13, weight: .heavy))
                            }
                            .foregroundStyle(gender == option ? .white : Pixel.ink)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                Rectangle().fill(gender == option ? Pixel.red : .white)
                                    .overlay(Rectangle().strokeBorder(Pixel.ink, lineWidth: 3))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }


            FieldLabel("HEIGHT") {
                PixelStepper(value: $heightCm, range: 100...230, step: 1, unit: "cm")
            }

            Button("START", action: onStart)
                .buttonStyle(PixelButtonStyle(fill: Pixel.grass))
                .disabled(!nameValid)
                .opacity(nameValid ? 1 : 0.5)
        }
        .padding(20)
        .pixelPanel()
    }
}

// MARK: - Bits

/// A captioned form row in the pixel style.
struct FieldLabel<Content: View>: View {
    let title: String
    @ViewBuilder var content: () -> Content

    init(_ title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(Pixel.font(11, weight: .bold))
                .foregroundStyle(Pixel.ink.opacity(0.7))
            content()
        }
    }
}

/// Chunky −/＋ stepper for numeric profile values.
struct PixelStepper: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    var step: Int = 1
    var unit: String

    var body: some View {
        HStack(spacing: 0) {
            stepButton("−") { value = max(range.lowerBound, value - step) }
            Text("\(value) \(unit)")
                .font(Pixel.font(16, weight: .heavy))
                .foregroundStyle(Pixel.ink)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.white)
            stepButton("+") { value = min(range.upperBound, value + step) }
        }
        .overlay(Rectangle().strokeBorder(Pixel.ink, lineWidth: 3))
    }

    private func stepButton(_ symbol: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(symbol)
                .font(Pixel.font(22, weight: .heavy))
                .foregroundStyle(.white)
                .frame(width: 52)
                .padding(.vertical, 12)
                .background(Pixel.red)
        }
        .buttonStyle(.plain)
    }
}

/// Wide background image scrolling right→left in a seamless loop.
struct ScrollingBackground: View {
    let imageName: String
    /// Scroll speed in points per second.
    var speed: CGFloat = 28

    @State private var animate = false

    var body: some View {
        GeometryReader { geo in
            let h = geo.size.height
            // Each tile is stretched to the full screen height (keeping aspect for
            // a natural width); two copies side by side loop seamlessly.
            let tile = h * aspectRatio
            HStack(spacing: 0) {
                image(width: tile, height: h)
                image(width: tile, height: h)
            }
            // Slide left: start at zero, end one tile to the left, repeat.
            .offset(x: animate ? -tile : 0)
            .frame(width: geo.size.width, height: h, alignment: .leading)
            .clipped()
            .animation(
                .linear(duration: Double(tile / speed)).repeatForever(autoreverses: false),
                value: animate
            )
            .onAppear { animate = true }
        }
        .ignoresSafeArea()
    }

    private func image(width: CGFloat, height: CGFloat) -> some View {
        Image(imageName)
            .resizable()
            .interpolation(.none)                 // keep pixel art crisp
            .frame(width: width, height: height)  // stretch to full screen height
    }

    /// Native aspect ratio (width / height) of the background art.
    private var aspectRatio: CGFloat {
        guard let img = UIImage(named: imageName), img.size.height > 0 else { return 3 }
        return img.size.width / img.size.height
    }
}

#Preview {
    OnboardingView()
}
