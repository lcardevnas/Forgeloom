import SwiftUI

// The shared components every screen reuses, built only from Theme.swift
// tokens. Copied from Forgeloom's professional-apple-ui skill; extend them here rather
// than restyling per screen.

extension View {
    /// A card: `card` fill, `Radius.card`, `Spacing.cardPadding`. No border, no shadow.
    func card(padding: CGFloat = Spacing.cardPadding) -> some View {
        self.padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.card, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
    }

    /// The one hero card per screen.
    func heroCard() -> some View {
        self.padding(Spacing.heroPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(AppTheme.onHero)
            .background(AppTheme.hero, in: RoundedRectangle(cornerRadius: Radius.hero, style: .continuous))
    }

    /// The window/screen background.
    func pageBackground() -> some View {
        self.background(AppTheme.canvas.ignoresSafeArea())
    }
}

/// A role: which tint and text pair a chip, badge or icon circle uses.
enum ToneRole {
    case brand, info, plan, attention, danger, onHero

    var fill: Color {
        switch self {
        case .brand: AppTheme.brandTint
        case .info: AppTheme.info
        case .plan: AppTheme.plan
        case .attention: AppTheme.attention
        case .danger: AppTheme.danger
        case .onHero: AppTheme.chipOnHero
        }
    }

    var text: Color {
        switch self {
        case .brand: AppTheme.onBrandTint
        case .info: AppTheme.onInfo
        case .plan: AppTheme.onPlan
        case .attention: AppTheme.onAttention
        case .danger: AppTheme.onDanger
        case .onHero: AppTheme.onHero
        }
    }
}

/// Status is a capsule with a symbol and a word, never color alone.
/// `StatusChip(L("Up to date"), symbol: "checkmark.circle.fill", role: .brand)`
struct StatusChip: View {
    let title: String
    let symbol: String
    let role: ToneRole

    init(_ title: String, symbol: String, role: ToneRole) {
        self.title = title
        self.symbol = symbol
        self.role = role
    }

    var body: some View {
        Label(title, systemImage: symbol)
            .font(.caption.weight(.semibold))
            .lineLimit(1)
            .padding(.horizontal, Spacing.m)
            .padding(.vertical, Spacing.xs + 1)
            .foregroundStyle(role.text)
            .background(role.fill, in: Capsule())
            .accessibilityElement(children: .combine)
    }
}

/// A count on a sidebar row or tab.
struct CountBadge: View {
    let count: Int
    var role: ToneRole = .attention

    var body: some View {
        Text(count, format: .number)
            .font(.caption2.weight(.bold))
            .monospacedDigit()
            .padding(.horizontal, Spacing.s)
            .padding(.vertical, 2)
            .foregroundStyle(role.text)
            .background(role.fill, in: Capsule())
    }
}

/// An SF Symbol in a 40 pt tinted circle, for stat cards and empty states.
struct IconCircle: View {
    let symbol: String
    var role: ToneRole = .brand
    var size: CGFloat = 40

    var body: some View {
        Image(systemName: symbol)
            .symbolRenderingMode(.hierarchical)
            .font(.system(size: size * 0.45, weight: .semibold))
            .foregroundStyle(role.text)
            .frame(width: size, height: size)
            .background(role.fill, in: Circle())
            .accessibilityHidden(true)
    }
}

/// Capsule buttons: `.buttonStyle(CapsuleButtonStyle(.primary))`.
struct CapsuleButtonStyle: ButtonStyle {
    enum Kind { case primary, secondary, destructive }
    let kind: Kind
    init(_ kind: Kind) { self.kind = kind }

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .lineLimit(1)
            .padding(.horizontal, Spacing.l)
            .padding(.vertical, Spacing.s)
            .foregroundStyle(foreground)
            .background(background, in: Capsule())
            .opacity(isEnabled ? (configuration.isPressed ? 0.8 : 1) : 0.45)
            .contentShape(Capsule())
    }

    private var foreground: Color {
        switch kind {
        case .primary: AppTheme.onPrimary
        case .secondary: AppTheme.text
        case .destructive: AppTheme.onDanger
        }
    }

    /// Secondary buttons use `card` so they stay visible on the canvas and in toolbars.
    private var background: Color {
        switch kind {
        case .primary: AppTheme.primary
        case .secondary: AppTheme.card
        case .destructive: AppTheme.danger
        }
    }
}

/// A section title with an optional trailing accessory ("See All", a count).
struct SectionHeader<Accessory: View>: View {
    let title: String
    @ViewBuilder var accessory: Accessory

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.title3.bold())
                .fontDesign(AppTheme.headingDesign)
                .foregroundStyle(AppTheme.text)
            Spacer(minLength: Spacing.m)
            accessory
        }
    }
}

extension SectionHeader where Accessory == EmptyView {
    init(_ title: String) {
        self.title = title
        self.accessory = EmptyView()
    }
}

/// A pill progress bar: `accent` on a `well` track.
struct PillProgressBar: View {
    let value: Double // 0…1

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(AppTheme.well)
                Capsule().fill(AppTheme.accent)
                    .frame(width: proxy.size.width * min(max(value, 0), 1))
            }
        }
        .frame(height: 6)
        .accessibilityElement()
        .accessibilityValue(Text(value, format: .percent.precision(.fractionLength(0))))
    }
}

/// A transparency checkerboard for images with alpha.
struct CheckerboardBackground: View {
    var square: CGFloat = 10

    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(AppTheme.well))
            let columns = Int(size.width / square) + 1
            let rows = Int(size.height / square) + 1
            for row in 0..<rows {
                for column in 0..<columns where (row + column).isMultiple(of: 2) {
                    let rect = CGRect(x: CGFloat(column) * square, y: CGFloat(row) * square, width: square, height: square)
                    context.fill(Path(rect), with: .color(AppTheme.checker))
                }
            }
        }
        .accessibilityHidden(true)
    }
}
