//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Yura on 25.04.25.
//

import UIKit
import CoreData

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    private(set) var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    
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
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
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
    
    func addCategory(name: String) {
        let category = TrackerCategoryCoreData(context: context)
        category.title = name
        try? context.save()
        try? fetchedResultsController?.performFetch()
    }
    
    func fetchCategories() -> [TrackerGroup] {
        try? fetchedResultsController?.performFetch()
        
        return fetchedResultsController?.fetchedObjects?.map { coreData in
            let name = coreData.title ?? ""
            let trackerObjects = (coreData.tracker?.allObjects as? [TrackerCoreData]) ?? []
            let trackers: [Tracker] = trackerObjects.compactMap { trackerCoreData in
                guard let id = trackerCoreData.id,
                      let name = trackerCoreData.title,
                      let icon = trackerCoreData.emoji,
                      let colorHex = trackerCoreData.color,
                      let color = UIColor(hex: colorHex) else {
                    return nil
                }
                
                let activeDays = convertCoreDataToSchedule(stringSchedule: trackerCoreData.schedule ?? "")
                
                return Tracker(
                    id: id,
                    name: name,
                    color: color,
                    icon: icon,
                    activeDays: Set(activeDays),
                    category: TrackerGroup(name: name, entries: [])
                )
            }
            
            return TrackerGroup(name: name, entries: trackers)
        } ?? []
    }
    
    func ensureDefaultCategoryExists(_ categoryName: String) {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", categoryName)
        
        let count = (try? context.count(for: request)) ?? 0
        guard count == 0 else { return }
        
        let category = TrackerCategoryCoreData(context: context)
        category.title = categoryName
        try? context.save()
        try? fetchedResultsController?.performFetch()
    }
    
    private func convertCoreDataToSchedule(stringSchedule: String) -> [WeekDay] {
        guard !stringSchedule.isEmpty else { return [] }
        
        return stringSchedule
            .components(separatedBy: ",")
            .compactMap { Int($0) }
            .compactMap { dayNumber in
                WeekDay.allCases.first { $0.dayNumber == dayNumber }
            }
    }
}
