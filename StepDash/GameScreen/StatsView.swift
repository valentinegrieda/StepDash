import SwiftUI
import SwiftData
import Charts

enum StatsPeriod: String, CaseIterable, Identifiable {
    case day = "D", week = "W", month = "M", year = "Y"
    var id: String { rawValue }
}

private struct StatsBar: Identifiable {
    let index: Int
    let label: String
    let steps: Int
    var id: Int { index }
}

/// The whole Stats card (purple header + off-white body). Self-contained — it
/// does not use the shared DashboardPanel frame.
struct StatsView: View {
    @Environment(\.modelContext) private var context
    @Query private var records: [DailyStepRecord]
    @Query private var players: [Player]

    @State private var period: StatsPeriod = .week
    @State private var hourlyBars: [StatsBar] = []

    private let purple = Color(hex: 0x655DD1)
    private let bodyBG = Color(hex: 0xF9F8F6)
    private let green  = Color(hex: 0x8BC34A)
    private let navy   = Color(hex: 0x2E3B52)
    private let monthSymbols = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

    private var calendar: Calendar {
        var c = Calendar.current
        c.firstWeekday = 2   // Monday
        return c
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("STATS")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(purple)

            VStack(spacing: 24) {
                segmented
                totalStepsRow
                twoBoxes
                chartCard
                Divider()
                coinsRow
            }
            .padding(16)
        }
        .background(bodyBG)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(.black.opacity(0.06), lineWidth: 1))
        .onAppear(perform: loadHourlyIfNeeded)
        .onChange(of: period) { _, _ in loadHourlyIfNeeded() }
    }

    // MARK: - Segmented D / W / M / Y

    private var segmented: some View {
        HStack(spacing: 0) {
            ForEach(StatsPeriod.allCases) { p in
                Text(p.rawValue)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(period == p ? Pixel.ink : Pixel.dMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(period == p ? Color(hex: 0xC4C2BC) : .clear)
                    )
                    .contentShape(Rectangle())
                    .onTapGesture { period = p }
            }
        }
        .padding(4)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: 0xE7E4DE)))
    }

    // MARK: - Totals

    private var totalStepsRow: some View {
        HStack(spacing: 14) {
            Spacer(minLength: 0)
            PixelIcon(name: "Shoe").frame(width: 50, height: 50)
            VStack(alignment: .leading, spacing: -1) {
                Text("Total Steps")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Pixel.dMuted)
                Text(stepFormatted(totalSteps))
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Pixel.ink)
            }
            Spacer(minLength: 0)
        }
    }

    private var twoBoxes: some View {
        HStack(spacing: 10) {
            infoBox(icon: "Gift", title: "Total Deliveries", value: "\(totalDeliveries)")
            infoBox(icon: "Map", title: "Total Distance", value: String(format: "%.2f km", totalDistanceKm))
        }
    }

    private func infoBox(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 10) {
            PixelIcon(name: icon).frame(width: 35, height: 35)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Pixel.dMuted)
                Text(value)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Pixel.ink)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(.black.opacity(0.06), lineWidth: 1))
    }

    // MARK: - Chart

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(chartTitle)
                    .font(Pixel.font(17, weight: .heavy))
                    .foregroundStyle(navy)
                Spacer()
                HStack(spacing: 5) {
                    RoundedRectangle(cornerRadius: 3).fill(green).frame(width: 14, height: 14)
                    Text("Steps")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Pixel.dMuted)
                }
            }

            Chart(bars) { bar in
                BarMark(
                    x: .value("Label", bar.label),
                    y: .value("Steps", bar.steps)
                )
                .foregroundStyle(green)
            }
            .chartXScale(domain: bars.map { $0.label })
            .chartXAxis {
                AxisMarks(values: xAxisLabels) { _ in
                    AxisValueLabel()
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    if let v = value.as(Int.self) {
                        AxisValueLabel { Text(kFormat(v)).font(.system(size: 11)) }
                    }
                }
            }
            .frame(height: 190)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(.black.opacity(0.06), lineWidth: 1))
    }

    private var coinsRow: some View {
        HStack(spacing: 10) {
            PixelIcon(name: "Coin").frame(width: 26, height: 26)
            Text("Coins earned")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Pixel.ink)
            Spacer()
            Text(stepFormatted(coinsEarned))
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Pixel.ink)
        }
    }

    // MARK: - Data

    private var periodStart: Date {
        let now = Date()
        switch period {
        case .day:   return calendar.startOfDay(for: now)
        case .week:  return calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? calendar.startOfDay(for: now)
        case .month: return calendar.dateInterval(of: .month, for: now)?.start ?? now
        case .year:  return calendar.dateInterval(of: .year, for: now)?.start ?? now
        }
    }

    private var recordsInRange: [DailyStepRecord] {
        let start = calendar.startOfDay(for: periodStart)
        return records.filter { $0.date >= start }
    }

    private var totalSteps: Int { recordsInRange.reduce(0) { $0 + $1.steps } }
    private var totalDeliveries: Int { recordsInRange.reduce(0) { $0 + $1.deliveriesDone } }
    private var totalDistanceKm: Double { recordsInRange.reduce(0.0) { $0 + $1.distance } / 1000 }
    private var coinsEarned: Int { recordsInRange.reduce(0) { $0 + $1.coinsEarned } }

    private var todayStepsValue: Int {
        records.first { calendar.isDate($0.date, inSameDayAs: Date()) }?.steps ?? 0
    }

    private var chartTitle: String {
        switch period {
        case .day:   return "Today"
        case .week:  return "This Week"
        case .month: return "This Month"
        case .year:  return "This Year"
        }
    }

    private func steps(on day: Date) -> Int {
        records.first { calendar.isDate($0.date, inSameDayAs: day) }?.steps ?? 0
    }

    private var bars: [StatsBar] {
        switch period {
        case .day:   return hourlyBars
        case .week:  return weekBars
        case .month: return monthBars
        case .year:  return yearBars
        }
    }

    private var weekBars: [StatsBar] {
        guard let start = calendar.dateInterval(of: .weekOfYear, for: Date())?.start else { return [] }
        let symbols = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
        return (0..<7).compactMap { i in
            guard let day = calendar.date(byAdding: .day, value: i, to: start) else { return nil }
            return StatsBar(index: i, label: symbols[i], steps: steps(on: day))
        }
    }

    private var monthBars: [StatsBar] {
        guard let interval = calendar.dateInterval(of: .month, for: Date()) else { return [] }
        var days: [Date] = []
        var day = interval.start
        while day < interval.end {
            days.append(day)
            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }
        return days.enumerated().map { offset, day in
            StatsBar(index: offset, label: "\(calendar.component(.day, from: day))", steps: steps(on: day))
        }
    }

    private var yearBars: [StatsBar] {
        guard let interval = calendar.dateInterval(of: .year, for: Date()) else { return [] }
        
        var months: [Date] = []
        var m = interval.start
        while m < interval.end {
            months.append(m)
            guard let next = calendar.date(byAdding: .month, value: 1, to: m) else { break }
            m = next
        }
        return months.enumerated().map { offset, monthStart in
            let sum: Int
            if let mi = calendar.dateInterval(of: .month, for: monthStart) {
                sum = records.filter { $0.date >= mi.start && $0.date < mi.end }.reduce(0) { $0 + $1.steps }
            } else {
                sum = 0
            }
            let monthIndex = calendar.component(.month, from: monthStart) - 1
            let label = monthSymbols.indices.contains(monthIndex) ? monthSymbols[monthIndex] : "\(offset + 1)"
            return StatsBar(index: offset, label: label, steps: sum)
        }
    }

    private var xAxisLabels: [String] {
        switch period {
        case .week, .year: return bars.map { $0.label }
        case .day:         return bars.enumerated().filter { $0.offset % 6 == 0 }.map { $0.element.label }
        case .month:       return bars.enumerated().filter { $0.offset % 5 == 0 }.map { $0.element.label }
        }
    }

    private func loadHourlyIfNeeded() {
        guard period == .day else { return }
        MotionManager.shared.queryHourlySteps(for: Date()) { hours in
            // Always show the full 0–23 axis (hours with no data show as 0), like Fitness.
            let values = hours.isEmpty ? [Int](repeating: 0, count: 24) : hours
            hourlyBars = (0..<24).map { hour in
                StatsBar(index: hour, label: "\(hour)", steps: hour < values.count ? values[hour] : 0)
            }
        }
    }

    private func kFormat(_ value: Int) -> String {
        value >= 1000 ? "\(value / 1000)K" : "\(value)"
    }
}

#Preview("StatsView") {
    // In-memory container with some sample data so the chart renders.
    let container = try! ModelContainer(
        for: Player.self, Mission.self, DailyStepRecord.self, CurrentDelivery.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    // Seed a player
    let player = Player(name: "PLAYER", gender: "male", height: 175, stepLength: 0.72, coins: 420)
    container.mainContext.insert(player)

    // Seed the last 10 days of step records with simple increasing pattern
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    for i in 0..<10 {
        let day = calendar.date(byAdding: .day, value: -i, to: today)!
        let steps = 2000 + i * 800
        let distance = Double(steps) * 0.7 // rough meters estimate
        let record = DailyStepRecord(date: day, steps: steps, distance: distance, deliveriesDone: i % 3, coinsEarned: (i % 3) * 10)
        container.mainContext.insert(record)
    }

    return ScrollView {
        StatsView()
            .padding()
    }
    .background(Pixel.screenBackground)
    .modelContainer(container)
}

