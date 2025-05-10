//
//  TrackerStore.swift
//  Tracker
//
//  Created by Yura on 25.04.25.
//

import UIKit
import CoreData

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private(set) var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    
    weak var delegate: NSFetchedResultsControllerDelegate? {
        didSet {
            fetchedResultsController?.delegate = delegate
        }
    }
    
    init(context: NSManagedObjectContext = CoreDataSource.shared.context) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        controller.delegate = delegate
        try? controller.performFetch()
        self.fetchedResultsController = controller
    }
    
    func addTracker(_ tracker: Tracker, categoryName: String) throws {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", categoryName)
        
        guard let category = try? context.fetch(request).first else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Категория '\(categoryName)' не найдена"])
        }
        
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.title = tracker.name
        trackerCoreData.emoji = tracker.icon
        trackerCoreData.color = tracker.color.hexString
        trackerCoreData.schedule = convertScheduleToCoreData(schedule: Array(tracker.activeDays))
        trackerCoreData.category = category
        
        try context.save()
        try? fetchedResultsController?.performFetch()
    }
    
    func fetchTrackers() -> [Tracker] {
        try? fetchedResultsController?.performFetch()
        
        return fetchedResultsController?.fetchedObjects?.compactMap { coreData in
            guard let id = coreData.id,
                  let name = coreData.title,
                  let emoji = coreData.emoji,
                  let colorHex = coreData.color,
                  let color = UIColor(hex: colorHex),
                  let category = coreData.category,
                  let categoryName = category.title else {
                return nil
            }
            
            let activeDays = convertCoreDataToSchedule(stringSchedule: coreData.schedule ?? "")
            
            return Tracker(
                id: id,
                name: name,
                color: color,
                icon: emoji,
                activeDays: Set(activeDays),
                category: TrackerGroup(name: categoryName, entries: [])
            )
        } ?? []
    }
    
    func fetchOrCreateCategory(with name: String) throws -> TrackerCategoryCoreData {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", name)
        
        if let existingCategory = try? context.fetch(request).first {
            return existingCategory
        }
        
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.title = name
        try context.save()
        return newCategory
    }
    
    func convertCoreDataToSchedule(stringSchedule: String) -> [WeekDay] {
        guard !stringSchedule.isEmpty else { return [] }
        
        return stringSchedule
            .components(separatedBy: ",")
            .compactMap { Int($0) }
            .compactMap { dayNumber in
                WeekDay.allCases.first { $0.dayNumber == dayNumber }
            }
    }
    
    func convertScheduleToCoreData(schedule: [WeekDay]) -> String {
        schedule.map { String($0.dayNumber) }.joined(separator: ",")
    }
}
