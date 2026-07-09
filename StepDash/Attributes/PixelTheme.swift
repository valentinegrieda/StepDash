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
