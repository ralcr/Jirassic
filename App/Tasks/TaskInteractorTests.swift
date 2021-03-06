//
//  TaskInteractorTests.swift
//  Jirassic
//
//  Created by Cristian Baluta on 07/05/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import XCTest
@testable import Jirassic_no_cloud

class TaskInteractorTests: XCTestCase {

    func testSaveDelete() {
        
        let repository = InMemoryCoreDataRepository()
        let interactor = TaskInteractor(repository: repository, remoteRepository: nil)
        
        let tasksBeforeInsert = repository.queryTasks(startDate: Date().startOfDay(), endDate: Date().endOfDay())
        XCTAssert(tasksBeforeInsert.count == 0, "We added one task, we should receive one task")
        
        let task = Task(endDate: Date(), type: TaskType.issue)
        interactor.saveTask(task, allowSyncing: false, completion: { task in })
        
        let tasks = repository.queryTasks(startDate: Date().startOfDay(), endDate: Date().endOfDay())
        XCTAssert(tasks.count == 1, "We added one task, we should receive one task")
        
        let taskToDelete = tasks.first!
        interactor.deleteTask(taskToDelete)
        
        let tasksAfterDelete = repository.queryTasks(startDate: Date().startOfDay(), endDate: Date().endOfDay())
        XCTAssert(tasksAfterDelete.count == 0, "There should be no tasks left")
    }
}
