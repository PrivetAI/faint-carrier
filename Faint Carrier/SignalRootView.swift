import SwiftUI

struct SignalRootView: View {
    @EnvironmentObject var game: SignalGame
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            SignalTheme.bg.edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case 0:
                        NavigationView { ObservatoryView() }
                            .navigationViewStyle(StackNavigationViewStyle())
                    case 1:
                        NavigationView { DecodeView() }
                            .navigationViewStyle(StackNavigationViewStyle())
                    case 2:
                        NavigationView { ArchiveView() }
                            .navigationViewStyle(StackNavigationViewStyle())
                    default:
                        NavigationView { SettingsView() }
                            .navigationViewStyle(StackNavigationViewStyle())
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                tabBar
            }
        }
        .onAppear { game.startTicking() }
        .onDisappear { game.stopTicking() }
        // Single sheet for the offline-earnings summary (iOS 15: only one .sheet honored).
        .sheet(item: $game.offlineSummary) { summary in
            OfflineSummarySheet(summary: summary)
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton(0, "Observatory", AnyView(DishIcon(size: 24, color: tabColor(0))))
            tabButton(1, "Decode", AnyView(DecodeIcon(size: 24, color: tabColor(1))))
            tabButton(2, "Archive", AnyView(ArchiveIcon(size: 24, color: tabColor(2))))
            tabButton(3, "Settings", AnyView(GearIcon(size: 24, color: tabColor(3))))
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(
            SignalTheme.card
                .overlay(Rectangle().fill(SignalTheme.stroke.opacity(0.5)).frame(height: 0.5), alignment: .top)
                .edgesIgnoringSafeArea(.bottom)
        )
    }

    private func tabColor(_ index: Int) -> Color {
        selectedTab == index ? SignalTheme.accent : SignalTheme.textFaint
    }

    private func tabButton(_ index: Int, _ label: String, _ icon: AnyView) -> some View {
        Button(action: { selectedTab = index }) {
            VStack(spacing: 4) {
                icon.frame(height: 24)
                Text(label)
                    .font(.system(size: 10, weight: selectedTab == index ? .semibold : .regular, design: .rounded))
                    .foregroundColor(tabColor(index))
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
