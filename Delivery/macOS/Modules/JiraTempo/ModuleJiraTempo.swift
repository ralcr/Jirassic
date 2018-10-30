//
//  JiraTempo.swift
//  Jirassic
//
//  Created by Cristian Baluta on 24/01/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation

class ModuleJiraTempo {
    
    let repository: JiraRepository!
    private let localPreferences = RCPreferences<LocalPreferences>()
    var isReachable: Bool {
        return localPreferences.string(.settingsJiraUrl) != ""
            && localPreferences.string(.settingsJiraUser) != ""
            && Keychain.getPassword() != ""
            && localPreferences.string(.settingsJiraProjectKey) != ""
            && localPreferences.string(.settingsJiraProjectIssueKey) != ""
    }
    
    init() {
        repository = JiraRepository(url: localPreferences.string(.settingsJiraUrl),
                                    user: localPreferences.string(.settingsJiraUser),
                                    password: Keychain.getPassword())
    }
    
    func fetchProjects (success: @escaping ([JProject]) -> Void, failure: @escaping (Error) -> Void) {
        repository.fetchProjects(success: success, failure: failure)
    }
    
    func fetchProjectIssues (projectKey: String, completion: @escaping (([JProjectIssue]?) -> Void)) {
        repository.fetchProjectIssues(projectKey: projectKey, completion: completion)
    }
    
    func postWorklog (worklog: String,
                      duration: Double,
                      date: Date,
                      success: @escaping () -> Void,
                      failure: @escaping (Error) -> Void) {
        
        let project = JProject(id: localPreferences.string(.settingsJiraProjectId),
                               key: localPreferences.string(.settingsJiraProjectKey),
                               name: "",
                               url: "")
        let projectIssue = JProjectIssue(id: "",
                                         key: localPreferences.string(.settingsJiraProjectIssueKey),
                                         url: "")

        repository.postWorklog(worklog, duration: duration, in: project, to: projectIssue, date: date, success: {
            success()
        }, failure: { error in
            failure(error)
        })
    }

//    func upload (reports: [Report]) {
//        var comment = ""
//        var duration = 0.0
//        for report in reports {
//            comment += report.taskNumber + " - " + report.title + "\n" + report.notes + "\n\n"
//            duration += report.duration
//        }
//    }
}
