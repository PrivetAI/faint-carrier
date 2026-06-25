import SwiftUI

// A bounded progress bar fed VALUE TYPES (not a class) to avoid the redraw-skip pitfall.
struct SignalBar: View {
    var fraction: Double   // 0..1 (value type → reliably re-renders)
    var color: Color
    var height: CGFloat = 8

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height/2)
                    .fill(SignalTheme.cardRaised)
                RoundedRectangle(cornerRadius: height/2)
                    .fill(
                        LinearGradient(colors: [color.opacity(0.7), color],
                                       startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: max(0, min(1, fraction)) * geo.size.width)
            }
        }
        .frame(height: height)
    }
}

struct SignalCard<Content: View>: View {
    var content: () -> Content
    init(@ViewBuilder content: @escaping () -> Content) { self.content = content }
    var body: some View {
        content()
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(SignalTheme.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(SignalTheme.stroke.opacity(0.6), lineWidth: 1)
                    )
            )
    }
}

struct SignalHeader: View {
    var title: String
    var subtitle: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(SignalTheme.text)
            if let s = subtitle {
                Text(s)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(SignalTheme.textDim)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct OfflineSummarySheet: View {
    let summary: SignalGame.OfflineSummary
    @Environment(\.presentationMode) private var presentationMode

    private var elapsedText: String {
        let s = Int(summary.seconds)
        let h = s / 3600, m = (s % 3600) / 60
        if h > 0 { return "\(h)h \(m)m" }
        if m > 0 { return "\(m)m" }
        return "\(s)s"
    }

    var body: some View {
        ZStack {
            SignalTheme.bg.edgesIgnoringSafeArea(.all)
            VStack(spacing: 22) {
                Spacer()
                ZStack {
                    ForEach(0..<3) { i in
                        Circle()
                            .stroke(SignalTheme.accent.opacity(0.3 - Double(i)*0.08), lineWidth: 2)
                            .frame(width: 80 + CGFloat(i)*34, height: 80 + CGFloat(i)*34)
                    }
                    DishIcon(size: 54, color: SignalTheme.accent)
                }
                .frame(height: 150)

                Text("While You Were Away")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(SignalTheme.text)

                VStack(spacing: 6) {
                    Text(SignalFormat.short(summary.earned))
                        .font(.system(size: 38, weight: .heavy, design: .rounded))
                        .foregroundColor(SignalTheme.accent)
                    Text("Signal collected over \(elapsedText)")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(SignalTheme.textDim)
                    if summary.capped {
                        Text("Collection capped at 8 hours")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(SignalTheme.amber)
                            .padding(.top, 2)
                    }
                }

                Spacer()

                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Text("Resume Listening")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(SignalTheme.bgDeep)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 14).fill(SignalTheme.accent))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 20)
        }
    }
}
