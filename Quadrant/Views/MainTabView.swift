import SwiftUI

enum TabItem: Int, CaseIterable {
    case history = 0
    case quadrant = 1
    case settings = 2

    var icon: String {
        switch self {
        case .history: return "envelope"
        case .quadrant: return "plus"
        case .settings: return "gearshape"
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: TabItem = .quadrant
    @State private var showAddSheet = false

    var body: some View {
        VStack(spacing: 0) {
            // Content
            Group {
                switch selectedTab {
                case .history:
                    HistoryView()
                case .quadrant:
                    QuadrantView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom tab bar
            Divider()
            HStack {
                ForEach(TabItem.allCases, id: \.rawValue) { tab in
                    Spacer()
                    Button {
                        if tab == .quadrant {
                            showAddSheet = true
                        } else {
                            selectedTab = tab
                        }
                    } label: {
                        Image(systemName: tab.icon)
                            .font(.system(size: tab == .quadrant ? 24 : 20))
                            .foregroundColor(
                                tab == .quadrant ? .primary :
                                (selectedTab == tab ? .primary : .secondary.opacity(0.5))
                            )
                            .frame(width: 44, height: 44)
                    }
                    Spacer()
                }
            }
            .padding(.bottom, 8)
        }
        .sheet(isPresented: $showAddSheet) {
            TaskEditorSheet()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}
