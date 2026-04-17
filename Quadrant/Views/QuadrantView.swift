import SwiftUI

struct QuadrantView: View {
    @Environment(TaskStore.self) private var taskStore
    @Environment(SettingsStore.self) private var settings
    @State private var editingTask: TaskItem?

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                QuadrantCell(quadrant: .urgentImportant, editingTask: $editingTask)
                dividerVertical
                QuadrantCell(quadrant: .importantNotUrgent, editingTask: $editingTask)
            }

            dividerHorizontal

            HStack(spacing: 0) {
                QuadrantCell(quadrant: .urgentNotImportant, editingTask: $editingTask)
                dividerVertical
                QuadrantCell(quadrant: .notUrgentNotImportant, editingTask: $editingTask)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .sheet(item: $editingTask) { task in
            TaskEditorSheet(editingTask: task, defaultQuadrant: task.quadrant)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    private var dividerVertical: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(width: 1)
    }

    private var dividerHorizontal: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(height: 1)
    }
}

// MARK: - Quadrant Cell

struct QuadrantCell: View {
    let quadrant: QuadrantType
    @Binding var editingTask: TaskItem?
    @Environment(TaskStore.self) private var taskStore
    @Environment(SettingsStore.self) private var settings

    private var quadrantColor: Color {
        switch quadrant {
        case .urgentImportant: return .red
        case .importantNotUrgent: return .orange
        case .urgentNotImportant: return .green
        case .notUrgentNotImportant: return .purple
        }
    }

    private var backgroundColor: Color {
        switch quadrant {
        case .urgentImportant: return Color.red.opacity(0.03)
        case .importantNotUrgent: return Color.orange.opacity(0.03)
        case .urgentNotImportant: return Color.green.opacity(0.03)
        case .notUrgentNotImportant: return Color.purple.opacity(0.03)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(quadrant.localizedName(language: settings.language))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(quadrantColor)
                .padding(.top, 8)
                .padding(.horizontal, 8)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    let tasks = taskStore.tasksFor(quadrant: quadrant, hideCompleted: settings.hideCompleted)
                    ForEach(tasks) { task in
                        TaskRowView(task: task, onTap: {
                            editingTask = task
                        })
                        .draggable(task.id.uuidString)
                    }
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(backgroundColor)
        .contentShape(Rectangle())
        .dropDestination(for: String.self) { items, _ in
            guard let idString = items.first, let uuid = UUID(uuidString: idString) else { return false }
            if let task = taskStore.tasks.first(where: { $0.id == uuid }) {
                taskStore.moveTask(task, to: quadrant)
            }
            return true
        }
    }
}

// MARK: - Task Row

struct TaskRowView: View {
    let task: TaskItem
    var onTap: () -> Void
    @Environment(TaskStore.self) private var taskStore

    private var checkboxColor: Color {
        switch task.quadrant {
        case .urgentImportant: return .red
        case .importantNotUrgent: return .orange
        case .urgentNotImportant: return .green
        case .notUrgentNotImportant: return .purple
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            Button {
                taskStore.toggleComplete(task)
            } label: {
                if task.isCompleted {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(checkboxColor)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(checkboxColor.opacity(0.4), lineWidth: 1.5)
                        .frame(width: 16, height: 16)
                }
            }
            .buttonStyle(.plain)

            Text(task.title)
                .font(.caption)
                .lineLimit(2)
                .truncationMode(.tail)
                .strikethrough(task.isCompleted, color: .gray)
                .foregroundColor(task.isCompleted ? .gray : .primary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}
