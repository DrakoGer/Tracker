//
//  Tracker.swift
//  Tracker
//
//  Created by Yura on 12.04.25.
//


import Foundation

struct Tracker {
    let id: UUID
    let name: String
    let color: String
    let icon: String
    let activeDays: Set<WeekDay>
}
