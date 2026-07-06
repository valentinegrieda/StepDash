import SwiftUI

/// The bottom tab bar for the Home screen — a replica of the destination pages'
/// toolbar so the two match (floating navy pill, selected-item highlight).
/// Driven by `GameUIConfig` + `ToolbarMetrics`.
struct GameBottomToolbar: View {
    let selected: ToolbarDestination
    var onSelect: (ToolbarDestination) -> Void

    var body: some View {
        let columns = Array(
            repeating: GridItem(.flexible(minimum: 0), spacing: 0),
            count: GameUIConfig.toolbarItems.count
        )

        return LazyVGrid(columns: columns, spacing: 0) {
            ForEach(GameUIConfig.toolbarItems) { item in
                button(item)
            }
        }
        .padding(.vertical, ToolbarMetrics.verticalPadding)
        .frame(height: ToolbarMetrics.toolbarHeight)
        .background(
            RoundedRectangle(cornerRadius: ToolbarMetrics.cornerRadius)
                .fill(Color(red: 0.05, green: 0.16, blue: 0.25).opacity(0.92))
        )
        .overlay(
            RoundedRectangle(cornerRadius: ToolbarMetrics.cornerRadius)
                .strokeBorder(Color(red: 0.12, green: 0.28, blue: 0.40), lineWidth: 2)
        )
        // Horizontal inset matches the delivery box (12) so the widths line up.
        .padding(.horizontal, 12)
        // ↓ LOWER / RAISE the whole bottom cluster by changing this number.
        .padding(.bottom, 12)
    }

    private func button(_ item: GameToolbarItem) -> some View {
        let isSelected = item.destination == selected

        return Button {
            onSelect(item.destination)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: ToolbarMetrics.activeCornerRadius)
                    .fill(isSelected ? Color(red: 0.11, green: 0.28, blue: 0.39) : .clear)
                    .padding(.horizontal, ToolbarMetrics.itemHorizontalInset)

                VStack(spacing: 0) {
                    icon(item, isSelected: isSelected)

                    Text(item.title)
                        .font(.custom("AvenirNext-Heavy", size: ToolbarMetrics.titleFontSize))
                        .foregroundStyle(isSelected ? .yellow : .white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(height: ToolbarMetrics.titleHeight)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: ToolbarMetrics.buttonHeight)
        }
        .buttonStyle(.plain)
    }

    private func icon(_ item: GameToolbarItem, isSelected: Bool) -> some View {
        PixelIcon(name: item.iconName)
            .frame(
                width: isSelected ? ToolbarMetrics.selectedIconSide : ToolbarMetrics.iconSide,
                height: isSelected ? ToolbarMetrics.selectedIconSide : ToolbarMetrics.iconSide
            )
            .frame(height: ToolbarMetrics.iconFrameHeight)
            .opacity(isSelected ? 1 : 0.86)
            .shadow(color: .black.opacity(0.35), radius: 1, x: 0, y: 1)
    }
}
