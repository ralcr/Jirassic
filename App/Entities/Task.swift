//
//  Task.swift
//  Jirassic
//
//  Created by Baluta Cristian on 21/11/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

// Never change the indexes because they are stored in the database
enum TaskType: Int {
	
	case issue = 0
	case startDay = 1
	case scrum = 2
	case lunch = 3
	case meeting = 4
    case gitCommit = 5
    case waste = 6
    case learning = 7
    case coderev = 8
    case endDay = 9
    case calendar = 10
    
    var defaultNotes: String {
        switch self {
        case .startDay: return "Working day started"
        case .endDay: return "Working day ended"
        case .scrum: return "Scrum meeting"
        case .lunch: return "Lunch break"
        case .meeting: return "Meeting"
        case .waste: return "Social & Media"
        case .learning: return "Learning session"
        case .coderev: return "Reviewing and fixing code reviews"
        case .calendar: return "Calendar event"
        default: return ""
        }
    }
    
    var defaultTaskNumber: String? {
        switch self {
        case .scrum: return "scrum"
        case .lunch: return "lunch"
        case .meeting: return "meeting"
        case .waste: return "waste"
        case .learning: return "learning"
        case .coderev: return "coderev"
        case .calendar: return "meeting"
        default: return nil
        }
    }
}

// Object representing a task
struct Task {
    
    var lastModifiedDate: Date?
    var startDate: Date?
	var endDate: Date
	var notes: String?
    var taskNumber: String?
    var taskTitle: String?
	var taskType: TaskType
    var objectId: String
}

extension Task {
	
    init () {
        self.endDate = Date()
        self.taskType = .issue
        self.objectId = String.generateId()
    }
    
	init (endDate: Date, type: TaskType) {
		
		self.endDate = endDate
        self.taskType = type
        self.taskNumber = type.defaultTaskNumber
        self.objectId = String.generateId()
	}
}

typealias TaskCreationData = (
    dateStart: Date?,
    dateEnd: Date,
    taskNumber: String,
    notes: String,
    taskType: TaskType
)
