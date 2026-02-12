import WidgetKit
import SwiftUI

// MARK: - VYRIS Watch Widget
// Ultra-minimal complication/widget for watchOS.
// Shows VYRIS mark with "Present" affordance. Tap opens Watch app QR screen.

struct VYRISWatchWidget: Widget {
    let kind = "VYRISWatchWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VYRISWidgetProvider()) { entry in
            VYRISWidgetEntryView(entry: entry)
                .containerBackground(.black, for: .widget)
                .widgetURL(URL(string: "vyris://watch/qr"))
        }
        .configurationDisplayName("VYRIS")
        .description("Quick access to present your card.")
        .supportedFamilies(supportedFamilies)
    }

    private var supportedFamilies: [WidgetFamily] {
        [
            .accessoryCircular,
            .accessoryCorner,
            .accessoryRectangular,
            .accessoryInline,
        ]
    }
}

// MARK: - Timeline Provider

struct VYRISWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> VYRISWidgetEntry {
        VYRISWidgetEntry(date: .now, cardName: "VYRIS")
    }

    func getSnapshot(in context: Context, completion: @escaping (VYRISWidgetEntry) -> Void) {
        let entry = VYRISWidgetEntry(date: .now, cardName: loadActiveCardName())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<VYRISWidgetEntry>) -> Void) {
        let entry = VYRISWidgetEntry(date: .now, cardName: loadActiveCardName())
        let timeline = Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(3600)))
        completion(timeline)
    }

    private func loadActiveCardName() -> String {
        // Read from shared UserDefaults (app group) or default
        if let data = UserDefaults(suiteName: "group.com.vyris.shared")?.data(forKey: "activeCardName"),
           let name = String(data: data, encoding: .utf8), !name.isEmpty {
            return name
        }
        return "VYRIS"
    }
}

// MARK: - Widget Entry

struct VYRISWidgetEntry: TimelineEntry {
    let date: Date
    let cardName: String
}

// MARK: - Widget Entry View

struct VYRISWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: VYRISWidgetEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            circularView
        case .accessoryCorner:
            cornerView
        case .accessoryRectangular:
            rectangularView
        case .accessoryInline:
            inlineView
        default:
            circularView
        }
    }

    private var circularView: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 1) {
                Image(systemName: "qrcode")
                    .font(.system(size: 16, weight: .light))
                Text("V")
                    .font(.system(size: 8, weight: .medium, design: .serif))
                    .tracking(1)
            }
        }
    }

    private var cornerView: some View {
        Image(systemName: "qrcode")
            .font(.system(size: 20, weight: .light))
            .widgetLabel {
                Text("Reveal")
                    .font(.system(size: 10))
            }
    }

    private var rectangularView: some View {
        HStack(spacing: 6) {
            Image(systemName: "qrcode")
                .font(.system(size: 22, weight: .light))

            VStack(alignment: .leading, spacing: 1) {
                Text("VYRIS")
                    .font(.system(size: 10, weight: .medium, design: .serif))
                    .tracking(1.5)
                Text(entry.cardName)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()
        }
    }

    private var inlineView: some View {
        HStack(spacing: 4) {
            Image(systemName: "qrcode")
            Text("VYRIS · Reveal")
        }
    }
}

// MARK: - Widget Bundle

@main
struct VYRISWidgetBundle: WidgetBundle {
    var body: some Widget {
        VYRISWatchWidget()
    }
}
