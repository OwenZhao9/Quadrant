import SwiftUI

struct HistoryView: View {
    @Environment(TaskStore.self) private var taskStore
    @Environment(SettingsStore.self) private var settings
    @State private var selectedDate: Date = Date()
    @State private var showCalendar = false
    
    private var calendar: Calendar { Calendar.current }
    
    private var weekDates: [Date] {
        let start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }
    
    private var completedTasksByQuadrant: [(QuadrantType, [TaskItem])] {
        QuadrantType.allCases.compactMap { quadrant in
            let tasks = taskStore.completedTasks(on: selectedDate).filter { $0.quadrant == quadrant }
            return tasks.isEmpty ? nil : (quadrant, tasks)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Date header
            dateHeader
            
            // Week day selector
            weekSelector
                .padding(.vertical, 8)
            
            
            // Completed tasks grouped by quadrant
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(completedTasksByQuadrant, id: \.0) { quadrant, tasks in
                        HistoryQuadrantSection(quadrant: quadrant, tasks: tasks)
                    }
                    
                    if completedTasksByQuadrant.isEmpty {
                        VStack(spacing: 12) {
                            Spacer().frame(height: 60)
                            Image(systemName: "tray")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary.opacity(0.4))
                            Text(settings.language == .chinese ? "今天没有已完成的任务" : "No completed tasks today")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 16)
            }
            
            Spacer()
        }
        .sheet(isPresented: $showCalendar) {
            CalendarSheet(selectedDate: $selectedDate)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Date Header
    
    private var dateHeader: some View {
        Button {
            showCalendar = true
        } label: {
            HStack(spacing: 4) {
                Text(formattedDate(selectedDate))
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                Image(systemName: "chevron.down")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Week Selector
    
    private var weekSelector: some View {
        HStack(spacing: 0) {
            ForEach(weekDates, id: \.self) { date in
                let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                let isToday = calendar.isDateInToday(date)
                let hasCompleted = taskStore.hasCompletedTasks(on: date)
                
                VStack(spacing: 4) {
                    Text(weekdayShort(date))
                        .font(.system(size: 10))
                        .foregroundColor(isSelected ? .primary : .secondary)
                    
                    ZStack {
                        if isSelected {
                            Circle()
                                .fill(Color.primary)
                                .frame(width: 32, height: 32)
                        }
                        
                        Text("\(calendar.component(.day, from: date))")
                            .font(.system(size: 14, weight: isSelected ? .bold : .regular))
                            .foregroundColor(isSelected ? Color(UIColor.systemBackground) : (isToday ? .blue : .primary))
                    }
                    
                    // Dot indicator for dates with completed tasks
                    Circle()
                        .fill(hasCompleted ? Color.red : Color.clear)
                        .frame(width: 4, height: 4)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedDate = date
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Helpers
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        if settings.language == .chinese {
            formatter.locale = Locale(identifier: "zh_CN")
            formatter.dateFormat = "yyyy年M月d日"
        } else {
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "MMM d, yyyy"
        }
        return formatter.string(from: date)
    }
    
    private func weekdayShort(_ date: Date) -> String {
        let formatter = DateFormatter()
        if settings.language == .chinese {
            formatter.locale = Locale(identifier: "zh_CN")
            let weekdays = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
            let index = calendar.component(.weekday, from: date) - 1
            return weekdays[index]
        } else {
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "EEE"
            return formatter.string(from: date)
        }
    }
}

// MARK: - History Quadrant Section

struct HistoryQuadrantSection: View {
    let quadrant: QuadrantType
    let tasks: [TaskItem]
    @Environment(TaskStore.self) private var taskStore
    @Environment(SettingsStore.self) private var settings
    @State private var isExpanded = true
    
    private var dotColor: Color {
        switch quadrant {
        case .urgentImportant: return .red
        case .importantNotUrgent: return .orange
        case .urgentNotImportant: return .green
        case .notUrgentNotImportant: return .purple
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Section header
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 6) {
                    Circle()
                        .fill(dotColor)
                        .frame(width: 8, height: 8)
                    Text(quadrant.localizedName(language: settings.language))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Text("(\(tasks.count))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 0 : -90))
                }
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                ForEach(tasks) { task in
                    HistoryTaskRow(task: task)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

// MARK: - History Task Row

struct HistoryTaskRow: View {
    let task: TaskItem
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
        HStack(spacing: 8) {
            Button {
                taskStore.toggleComplete(task)
            } label: {
                if task.isCompleted {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(checkboxColor)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 20, height: 20)
                }
            }
            .buttonStyle(.plain)
            
            Text(task.title)
                .font(.subheadline)
                .lineLimit(2)
                .truncationMode(.tail)
                .strikethrough(task.isCompleted, color: .gray)
                .foregroundColor(task.isCompleted ? .secondary : .primary)
        }
        .padding(.leading, 4)
    }
}

// MARK: - Calendar Sheet

struct CalendarSheet: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    @Environment(SettingsStore.self) private var settings
    @State private var displayedMonth: Date = Date()
    
    private var calendar: Calendar { Calendar.current }
    
    private var monthTitle: String {
        let formatter = DateFormatter()
        if settings.language == .chinese {
            formatter.locale = Locale(identifier: "zh_CN")
            formatter.dateFormat = "yyyy年M月"
        } else {
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "MMMM yyyy"
        }
        return formatter.string(from: displayedMonth)
    }
    
    private var daysInMonth: [Date?] {
        let range = calendar.range(of: .day, in: .month, for: displayedMonth)!
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))!
        let firstWeekday = calendar.component(.weekday, from: firstDay) - 1
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        // Fill remaining cells
        while days.count % 7 != 0 {
            days.append(nil)
        }
        return days
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Month navigation
            HStack {
                Text(monthTitle)
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
                Button {
                    withAnimation {
                        displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth)!
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }
                Button {
                    withAnimation {
                        displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth)!
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal)
            
            // Weekday headers
            let weekdayHeaders: [String] = settings.language == .chinese
                ? ["日", "一", "二", "三", "四", "五", "六"]
                : ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            
            HStack(spacing: 0) {
                ForEach(weekdayHeaders, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Calendar grid
            let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                    if let date = date {
                        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                        let isToday = calendar.isDateInToday(date)
                        let isCurrentMonth = calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month)
                        
                        Button {
                            selectedDate = date
                            dismiss()
                        } label: {
                            ZStack {
                                if isSelected {
                                    Circle()
                                        .fill(Color.primary)
                                        .frame(width: 36, height: 36)
                                }
                                
                                Text("\(calendar.component(.day, from: date))")
                                    .font(.system(size: 15))
                                    .foregroundColor(
                                        isSelected ? Color(UIColor.systemBackground) :
                                        (isCurrentMonth ? .primary : .secondary.opacity(0.4))
                                    )
                            }
                            .frame(height: 36)
                            .frame(maxWidth: .infinity)
                            .overlay(alignment: .bottom) {
                                if isToday && !isSelected {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 4, height: 4)
                                        .offset(y: 2)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    } else {
                        Color.clear
                            .frame(height: 36)
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top, 24)
        .onAppear {
            displayedMonth = selectedDate
        }
    }
}
