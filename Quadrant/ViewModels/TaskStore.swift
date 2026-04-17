import Foundation
import SwiftUI

@Observable
class TaskStore {
    var tasks: [TaskItem] = []
    
    private let saveKey = "quadrant_tasks"
    
    init() {
        load()
    }
    
    // MARK: - CRUD
    
    func addTask(title: String, quadrant: QuadrantType) {
        let task = TaskItem(title: title, quadrant: quadrant)
        tasks.append(task)
        save()
    }
    
    func toggleComplete(_ task: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            tasks[index].completedAt = tasks[index].isCompleted ? Date() : nil
            save()
        }
    }
    
    func moveTask(_ task: TaskItem, to quadrant: QuadrantType) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].quadrant = quadrant
            save()
        }
    }
    
    func updateTask(_ task: TaskItem, title: String, quadrant: QuadrantType) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].title = title
            tasks[index].quadrant = quadrant
            save()
        }
    }

    func deleteTask(_ task: TaskItem) {
        tasks.removeAll { $0.id == task.id }
        save()
    }
    
    func tasksFor(quadrant: QuadrantType, hideCompleted: Bool) -> [TaskItem] {
        tasks.filter { $0.quadrant == quadrant && (!hideCompleted || !$0.isCompleted) }
    }
    
    // MARK: - History
    
    func completedTasks(on date: Date) -> [TaskItem] {
        let calendar = Calendar.current
        return tasks.filter { task in
            guard let completedAt = task.completedAt, task.isCompleted else { return false }
            return calendar.isDate(completedAt, inSameDayAs: date)
        }
    }
    
    func hasCompletedTasks(on date: Date) -> Bool {
        !completedTasks(on: date).isEmpty
    }
    
    // MARK: - Persistence
    
    private var fileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("tasks.json")
    }
    
    private func save() {
        do {
            let data = try JSONEncoder().encode(tasks)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save tasks: \(error)")
        }
    }
    
    private func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            tasks = try JSONDecoder().decode([TaskItem].self, from: data)
        } catch {
            tasks = []
        }
    }
}
