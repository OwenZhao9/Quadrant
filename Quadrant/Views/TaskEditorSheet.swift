import SwiftUI

struct TaskEditorSheet: View {
    @Environment(TaskStore.self) private var taskStore
    @Environment(SettingsStore.self) private var settings
    @Environment(\.dismiss) private var dismiss
    
    let editingTask: TaskItem?
    
    @State private var title: String
    @State private var selectedQuadrant: QuadrantType
    @FocusState private var isFocused: Bool
    
    var isEditing: Bool { editingTask != nil }
    
    init(editingTask: TaskItem? = nil, defaultQuadrant: QuadrantType = .urgentImportant) {
        self.editingTask = editingTask
        _title = State(initialValue: editingTask?.title ?? "")
        _selectedQuadrant = State(initialValue: editingTask?.quadrant ?? defaultQuadrant)
    }
    
    private func quadrantColor(for quadrant: QuadrantType) -> Color {
        switch quadrant {
        case .urgentImportant: return .red
        case .importantNotUrgent: return .orange
        case .urgentNotImportant: return .green
        case .notUrgentNotImportant: return .purple
        }
    }
    
    private func quadrantLabel(for quadrant: QuadrantType) -> String {
        quadrant.localizedName(language: settings.language)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top: checkbox + text field + close
            HStack(alignment: .center, spacing: 12) {
                // Checkbox
                RoundedRectangle(cornerRadius: 4)
                    .stroke(quadrantColor(for: selectedQuadrant), lineWidth: 2)
                    .frame(width: 22, height: 22)
                
                // Text editor
                TextField(
                    settings.language == .chinese ? "想要做什么..." : "What to do...",
                    text: $title,
                    axis: .vertical
                )
                .font(.body)
                .focused($isFocused)
                .onSubmit {
                    submitAction()
                }
                
                Spacer()
                
                // Close button
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            Spacer()
            
            // Bottom toolbar
            HStack(spacing: 12) {
                // Delete button
                Button {
                    if let task = editingTask {
                        taskStore.deleteTask(task)
                    }
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "trash")
                            .font(.system(size: 13))
                        Text(settings.language == .chinese ? "删除" : "Delete")
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color(UIColor.systemGray5))
                    )
                }
                .foregroundColor(.primary)
                
                // Add/Update button
                Button {
                    submitAction()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: isEditing ? "square.and.pencil" : "plus")
                            .font(.system(size: 13))
                        Text(isEditing
                             ? (settings.language == .chinese ? "更新" : "Update")
                             : (settings.language == .chinese ? "添加" : "Add"))
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color(UIColor.systemGray5))
                    )
                }
                .foregroundColor(.primary)
                
                // Quadrant selector
                Menu {
                    ForEach(QuadrantType.allCases) { q in
                        Button {
                            selectedQuadrant = q
                        } label: {
                            HStack {
                                Text(quadrantLabel(for: q))
                                if selectedQuadrant == q {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(quadrantColor(for: selectedQuadrant))
                            .frame(width: 8, height: 8)
                        Text(quadrantLabel(for: selectedQuadrant))
                            .font(.subheadline)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color(UIColor.systemGray5))
                    )
                }
                .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isFocused = true
            }
        }
    }
    
    private func submitAction() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        if let task = editingTask {
            taskStore.updateTask(task, title: trimmed, quadrant: selectedQuadrant)
        } else {
            taskStore.addTask(title: trimmed, quadrant: selectedQuadrant)
        }
        dismiss()
    }
}
