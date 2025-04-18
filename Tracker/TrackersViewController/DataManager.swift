//
//  DataManager.swift
//  Tracker
//
//  Created by Yura on 12.04.25.
//

import Foundation

final class DataManager {
    static let shared = DataManager()

    private init() {}
    var entryGroups: [TrackerGroup] = []

    private lazy var initialGroups: [TrackerGroup] = [
        TrackerGroup(name: "Уборка", entries: []),
        TrackerGroup(name: "Домашнее задание", entries: []),
    ]

    func addEntry(_ entry: Tracker, toGroupWithName name: String) {
        if let groupIndex = entryGroups.firstIndex(where: { $0.name == name }) {
            entryGroups[groupIndex].entries.append(entry)
        } else {
            let newGroup = TrackerGroup(name: name, entries: [entry])
            entryGroups.append(newGroup)
        }
    }

    func createGroup(_ group: TrackerGroup) {
        initialGroups.append(group)
    }
}
