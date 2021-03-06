//
//  SqliteRepository+Tasks.swift
//  Jirassic
//
//  Created by Cristian Baluta on 02/04/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation
import RCLog

extension SqliteRepository: RepositoryTasks {

    func queryTask (withId objectId: String) -> Task? {
        
        let taskPredicate = "objectId == '\(objectId)'"
        let tasks: [STask] = queryWithPredicate(taskPredicate, sortingKeyPath: nil)
        if let stask = tasks.first {
            return taskFromSTask(stask)
        }
        return nil
    }
    
    func queryTasks (startDate: Date, endDate: Date, predicate: NSPredicate? = nil) -> [Task] {

        let tasks = self.tasksBetween (startDate: startDate, endDate: endDate, predicate: predicate)
        return tasks
    }

    func queryTasks (startDate: Date, endDate: Date, predicate: NSPredicate? = nil, completion: @escaping ([Task], NSError?) -> Void) {

        queue.async {
            let tasks = self.queryTasks (startDate: startDate, endDate: endDate, predicate: predicate)
            completion(tasks, nil)
        }
    }
    
    func queryUnsyncedTasks() -> [Task] {

        #if !CMD
        RCLog("Query tasks since last sync date: \(String(describing: UserDefaults.standard.lastSyncDateWithRemote))")
        #endif
        var sinceDatePredicate = ""
        if let lastSyncDateWithRemote = UserDefaults.standard.lastSyncDateWithRemote {
            sinceDatePredicate = " OR datetime(lastModifiedDate) > datetime('\(lastSyncDateWithRemote.YYYYMMddHHmmssGMT())')"
        }
        let predicate = "(lastModifiedDate is NULL\(sinceDatePredicate)) AND markedForDeletion == 0"
        let results: [STask] = queryWithPredicate(predicate, sortingKeyPath: nil)
        let tasks = tasksFromSTasks(results)
        
        return tasks
    }
    
    func queryDeletedTasks (_ completion: @escaping ([Task]) -> Void) {
        
        let predicate = "markedForDeletion == 1"
        let results: [STask] = queryWithPredicate(predicate, sortingKeyPath: nil)
        let tasks = tasksFromSTasks(results)
        
        completion(tasks)
    }
    
    func queryUpdates (_ completion: @escaping ([Task], [String], NSError?) -> Void) {
        
        queryDeletedTasks { (deletedTasks) in
            let unsyncedTasks = self.queryUnsyncedTasks()
            let deletedTasksIds = deletedTasks.map{ $0.objectId! }
            completion(unsyncedTasks, deletedTasksIds, nil)
        }
    }
    
    func deleteTask (_ task: Task, permanently: Bool, completion: @escaping ((_ success: Bool) -> Void)) {
        
        let stask = staskFromTask(task)
        if permanently {
            completion( stask.delete() )
        } else {
            stask.markedForDeletion = true
            completion( stask.save() == 1 )
        }
    }
    
    func deleteTask (objectId: String, completion: @escaping ((_ success: Bool) -> Void)) {
        
        let taskPredicate = "objectId == '\(objectId)'"
        let tasks: [STask] = queryWithPredicate(taskPredicate, sortingKeyPath: nil)
        if let stask = tasks.first {
            completion( stask.delete() )
        } else {
            completion( false )
        }
    }
    
    func saveTask (_ task: Task, completion: @escaping ((_ task: Task?) -> Void)) {
        
        let stask = staskFromTask(task)
        let saved = stask.save()
        #if !CMD
        RCLog("Saved to sqlite \(saved) \(task)")
        #endif
        if saved == 1 {
            completion( taskFromSTask(stask))
        } else {
            completion(nil)
        }
    }
}

extension SqliteRepository {

    private func tasksBetween (startDate: Date, endDate: Date, predicate: NSPredicate? = nil) -> [Task] {

        let startDateString = startDate.YYYYMMddHHmmssGMT()
        let endDateString = endDate.YYYYMMddHHmmssGMT()
        var predicateComponents = ["datetime(endDate) BETWEEN datetime('\(startDateString)') AND datetime('\(endDateString)')",
                                    "markedForDeletion == 0"]
        if let p = predicate {
            predicateComponents.append("(\(p.predicateFormat))")
        }
        let sqlPredicate = predicateComponents.joined(separator: " AND ")
        
        let results: [STask] = queryWithPredicate(sqlPredicate, sortingKeyPath: "endDate")
        let tasks = tasksFromSTasks(results)

        return tasks
    }

    private func taskFromSTask (_ stask: STask) -> Task {
        
        return Task(lastModifiedDate: stask.lastModifiedDate,
                    startDate: stask.startDate,
                    endDate: stask.endDate!,
                    notes: stask.notes,
                    taskNumber: stask.taskNumber,
                    taskTitle: stask.taskTitle,
                    taskType: TaskType(rawValue: stask.taskType)!,
                    objectId: stask.objectId!
        )
    }
    
    private func tasksFromSTasks (_ rtasks: [STask]) -> [Task] {
        
        var tasks = [Task]()
        for rtask in rtasks {
            tasks.append( taskFromSTask(rtask) )
        }
        
        return tasks
    }
    
    private func staskFromTask (_ task: Task) -> STask {
        
        let taskPredicate = "objectId == '\(task.objectId!)'"
        let tasks: [STask] = queryWithPredicate(taskPredicate, sortingKeyPath: nil)
        var stask: STask? = tasks.first
        if stask == nil {
            stask = STask()
            stask!.objectId = task.objectId
        }
        
        return updatedSTask(stask!, withTask: task)
    }
    
    // Update only updatable properties. objectId can't be updated
    private func updatedSTask (_ stask: STask, withTask task: Task) -> STask {
        
        stask.taskNumber = task.taskNumber
        stask.taskType = task.taskType.rawValue
        stask.taskTitle = task.taskTitle
        stask.notes = task.notes
        stask.startDate = task.startDate
        stask.endDate = task.endDate
        stask.lastModifiedDate = task.lastModifiedDate
        
        return stask
    }
}
