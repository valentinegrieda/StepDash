//
//  PixelTheme.swift
//  iSense Test
//
//  Shared pixel-art look: palette, chunky panels, hard-shadow buttons.
//  Derived from the StepDash home-screen reference.
//

import SwiftUI

enum Pixel {
    // Palette pulled from the reference art.
    static let sky      = Color(red: 0.16, green: 0.55, blue: 0.85)
    static let skyDeep  = Color(red: 0.10, green: 0.40, blue: 0.70)
    static let cream    = Color(red: 0.97, green: 0.95, blue: 0.90)
    static let ink      = Color(red: 0.16, green: 0.13, blue: 0.18)
    static let red      = Color(red: 0.85, green: 0.20, blue: 0.20)
    static let wood     = Color(red: 0.55, green: 0.38, blue: 0.24)
    static let grass    = Color(red: 0.34, green: 0.68, blue: 0.30)
    static let coin     = Color(red: 0.98, green: 0.78, blue: 0.20)

    // UI chrome (the dashboard look from the reference screens).
    static let navy        = Color(red: 0.09, green: 0.16, blue: 0.31)
    static let navyDeep    = Color(red: 0.05, green: 0.09, blue: 0.19)
    static let panel       = Color(red: 0.96, green: 0.94, blue: 0.88)
    static let panelEdge   = Color(red: 0.84, green: 0.81, blue: 0.73)
    static let purple      = Color(red: 0.44, green: 0.40, blue: 0.86)
    static let purpleDeep  = Color(red: 0.35, green: 0.31, blue: 0.78)
    static let gem         = Color(red: 0.26, green: 0.62, blue: 0.92)
    static let textDark    = Color(red: 0.13, green: 0.15, blue: 0.22)
    static let textMuted   = Color(red: 0.45, green: 0.47, blue: 0.53)
    static let track       = Color(red: 0.86, green: 0.84, blue: 0.78)

    /// Full-screen dark background used behind the dashboard panels.
    static var screenBackground: LinearGradient {
        LinearGradient(colors: [navy, navyDeep],
                       startPoint: .top, endPoint: .bottom)
    }

    /// App-wide text face. SwiftUI's default system font resolves to SF Pro on iOS.
    static func font(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight)
    }

    /// Onboarding keeps the original pixel/monospaced feel while the rest of the
    /// app uses SF Pro.
    static func onboardingFont(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

// MARK: - Dashboard panel (cream card with purple titled header)

/// A titled dashboard panel: rounded cream card with a purple gradient header
/// bar, matching the reference screens (Stats / Missions / Shop / Profile).
struct DashboardPanel<Content: View>: View {
    let title: String
    var headerTrailing: AnyView? = nil
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            // Purple header
            HStack {
                Text(title)
                    .font(Pixel.font(17, weight: .heavy))
                    .foregroundStyle(.white)
                    .tracking(1)
                Spacer()
                if let headerTrailing { headerTrailing }
            }
            .padding(.horizontal, 18)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(colors: [Pixel.purple, Pixel.purpleDeep],
                               startPoint: .top, endPoint: .bottom)
            )

            // Body
            content()
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(Pixel.panel)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Pixel.navyDeep.opacity(0.35), lineWidth: 2))
        .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 6)
    }
}

/// A modal popup: dark backdrop + a titled dashboard panel with a red close X.
struct PopupContainer<Content: View>: View {
    let title: String
    @ViewBuilder var content: () -> Content
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Pixel.screenBackground.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                DashboardPanel(title: title, headerTrailing: AnyView(closeButton)) {
                    content()
                }
                .padding(16)
            }
        }
    }

    private var closeButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "xmark")
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(Pixel.red, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

/// Inset white "list" card used for grouped rows inside a panel.
struct InsetCard<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View {
        VStack(spacing: 0) { content() }
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Pixel.panelEdge, lineWidth: 1.5))
    }
}

/// Rounded progress bar (track + fill), used across the dashboard.
struct DashboardBar: View {
    let progress: Double
    var fill: Color
    var height: CGFloat = 10

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Pixel.track)
                Capsule().fill(fill)
                    .frame(width: max(0, geo.size.width * min(max(progress, 0), 1)))
            }
        }
        .frame(height: height)
    }
}

/// Small pill that shows a currency icon + amount (coins / gems).
struct CurrencyPill: View {
    enum Kind { case coin, gem }
    let kind: Kind
    let amount: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: kind == .coin ? "dollarsign.circle.fill" : "diamond.fill")
                .foregroundStyle(kind == .coin ? Pixel.coin : Pixel.gem)
            Text(amount)
                .font(Pixel.font(13, weight: .heavy))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Capsule().fill(Pixel.navyDeep.opacity(0.4)))
    }
}

// MARK: - Chunky panel (cream card, hard border + offset shadow)

struct PixelPanel: ViewModifier {
    var fill: Color = Pixel.cream
    var border: Color = Pixel.ink

    func body(content: Content) -> some View {
        content
            .background(
                Rectangle().fill(fill)
                    .overlay(Rectangle().strokeBorder(border, lineWidth: 3))
            )
            // Hard, un-blurred shadow gives the blocky retro depth.
            .background(
                Rectangle().fill(border).offset(x: 5, y: 5)
            )
    }
}

extension View {
    func pixelPanel(fill: Color = Pixel.cream, border: Color = Pixel.ink) -> some View {
        modifier(PixelPanel(fill: fill, border: border))
    }
}

// MARK: - Pixel button

struct PixelButtonStyle: ButtonStyle {
    var fill: Color = Pixel.red
    var textColor: Color = .white
    var labelFont: Font = Pixel.font(16, weight: .heavy)

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(labelFont)
            .foregroundStyle(textColor)
            .padding(.vertical, 14)
            .padding(.horizontal, 22)
            .frame(maxWidth: .infinity)
            .background(
                Rectangle().fill(fill)
                    .overlay(Rectangle().strokeBorder(Pixel.ink, lineWidth: 3))
            )
            .background(Rectangle().fill(Pixel.ink).offset(x: 4, y: 4))
            // Press = button drops onto its shadow.
            .offset(x: configuration.isPressed ? 4 : 0,
                    y: configuration.isPressed ? 4 : 0)
            .animation(.easeOut(duration: 0.05), value: configuration.isPressed)
    }
}
