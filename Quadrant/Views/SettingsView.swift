import SwiftUI

struct SettingsView: View {
    @Environment(SettingsStore.self) private var settings
    @State private var showCopiedToast = false
    
    var body: some View {
        @Bindable var settings = settings
        
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Personalization Section
                sectionHeader(settings.language == .chinese ? "个性化" : "Personalization")
                
                VStack(spacing: 0) {
                    // Theme
                    HStack {
                        Image(systemName: "star")
                            .foregroundColor(.primary)
                            .frame(width: 24)
                        Text(settings.language == .chinese ? "主题" : "Theme")
                            .font(.body)
                        Spacer()
                        themeSelector
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    
                    Divider().padding(.leading, 52)
                    
                    // Language
                    Menu {
                        ForEach(AppLanguage.allCases, id: \.self) { lang in
                            Button {
                                settings.language = lang
                            } label: {
                                if settings.language == lang {
                                    Label(lang.displayName, systemImage: "checkmark")
                                } else {
                                    Text(lang.displayName)
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.primary)
                                .frame(width: 24)
                            Text(settings.language == .chinese ? "语言" : "Language")
                                .font(.body)
                                .foregroundColor(.primary)
                            Spacer()
                            Text(settings.language.displayName)
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    
                    Divider().padding(.leading, 52)
                    
                    // Show completed items
                    HStack {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.primary)
                            .frame(width: 24)
                        Text(settings.language == .chinese ? "显示已完成事项" : "Show Completed Items")
                            .font(.body)
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { !settings.hideCompleted },
                            set: { settings.hideCompleted = !$0 }
                        ))
                        .labelsHidden()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
                
                // Support Section
                sectionHeader(settings.language == .chinese ? "支持与反馈" : "Support & Feedback")
                
                VStack(spacing: 0) {
                    // Email contact
                    Button {
                        UIPasteboard.general.string = settings.contactEmail
                        showCopiedToast = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showCopiedToast = false
                        }
                    } label: {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.primary)
                                .frame(width: 24)
                            Text(settings.language == .chinese ? "邮件联系" : "Contact via Email")
                                .font(.body)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
                
                Spacer().frame(height: 40)
                
                // Version
                HStack {
                    Spacer()
                    Text("\(settings.appVersion) (\(settings.buildNumber))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .overlay {
            if showCopiedToast {
                VStack {
                    Spacer()
                    Text(settings.language == .chinese ? "邮箱\(settings.contactEmail)已复制" : "Email \(settings.contactEmail) copied")
                        .font(.subheadline)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color(UIColor.systemGray3))
                        )
                        .padding(.bottom, 80)
                }
                .transition(.opacity)
                .animation(.easeInOut, value: showCopiedToast)
            }
        }
    }
    
    // MARK: - Theme Selector
    
    private var themeSelector: some View {
        HStack(spacing: 4) {
            themeButton(.light, icon: "sun.max.fill")
            themeButton(.dark, icon: "moon.fill")
            themeButton(.system, icon: "circle.lefthalf.filled")
        }
        .padding(3)
        .background(
            Capsule()
                .fill(Color(UIColor.systemGray5))
        )
    }
    
    private func themeButton(_ theme: AppTheme, icon: String) -> some View {
        Button {
            settings.theme = theme
        } label: {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(settings.theme == theme ? .white : .primary)
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .fill(settings.theme == theme ? Color.primary : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Section Header
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.leading, 4)
    }
}
