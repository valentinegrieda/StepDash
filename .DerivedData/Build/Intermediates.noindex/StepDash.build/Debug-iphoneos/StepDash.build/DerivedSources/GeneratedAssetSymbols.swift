import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "StepDashLogo" asset catalog image resource.
    static let stepDashLogo = DeveloperToolsSupport.ImageResource(name: "StepDashLogo", bundle: resourceBundle)

    /// The "bg" asset catalog image resource.
    static let bg = DeveloperToolsSupport.ImageResource(name: "bg", bundle: resourceBundle)

    /// The "player" asset catalog image resource.
    static let player = DeveloperToolsSupport.ImageResource(name: "player", bundle: resourceBundle)

    /// The "player_1" asset catalog image resource.
    static let player1 = DeveloperToolsSupport.ImageResource(name: "player_1", bundle: resourceBundle)

    /// The "player_2" asset catalog image resource.
    static let player2 = DeveloperToolsSupport.ImageResource(name: "player_2", bundle: resourceBundle)

    /// The "player_idle" asset catalog image resource.
    static let playerIdle = DeveloperToolsSupport.ImageResource(name: "player_idle", bundle: resourceBundle)

    /// The "player_walk1" asset catalog image resource.
    static let playerWalk1 = DeveloperToolsSupport.ImageResource(name: "player_walk1", bundle: resourceBundle)

    /// The "player_walk2" asset catalog image resource.
    static let playerWalk2 = DeveloperToolsSupport.ImageResource(name: "player_walk2", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "StepDashLogo" asset catalog image.
    static var stepDashLogo: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .stepDashLogo)
#else
        .init()
#endif
    }

    /// The "bg" asset catalog image.
    static var bg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bg)
#else
        .init()
#endif
    }

    /// The "player" asset catalog image.
    static var player: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .player)
#else
        .init()
#endif
    }

    /// The "player_1" asset catalog image.
    static var player1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .player1)
#else
        .init()
#endif
    }

    /// The "player_2" asset catalog image.
    static var player2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .player2)
#else
        .init()
#endif
    }

    /// The "player_idle" asset catalog image.
    static var playerIdle: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .playerIdle)
#else
        .init()
#endif
    }

    /// The "player_walk1" asset catalog image.
    static var playerWalk1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .playerWalk1)
#else
        .init()
#endif
    }

    /// The "player_walk2" asset catalog image.
    static var playerWalk2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .playerWalk2)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "StepDashLogo" asset catalog image.
    static var stepDashLogo: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .stepDashLogo)
#else
        .init()
#endif
    }

    /// The "bg" asset catalog image.
    static var bg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bg)
#else
        .init()
#endif
    }

    /// The "player" asset catalog image.
    static var player: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .player)
#else
        .init()
#endif
    }

    /// The "player_1" asset catalog image.
    static var player1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .player1)
#else
        .init()
#endif
    }

    /// The "player_2" asset catalog image.
    static var player2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .player2)
#else
        .init()
#endif
    }

    /// The "player_idle" asset catalog image.
    static var playerIdle: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .playerIdle)
#else
        .init()
#endif
    }

    /// The "player_walk1" asset catalog image.
    static var playerWalk1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .playerWalk1)
#else
        .init()
#endif
    }

    /// The "player_walk2" asset catalog image.
    static var playerWalk2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .playerWalk2)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

