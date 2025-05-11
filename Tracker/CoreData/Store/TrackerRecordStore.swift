//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Yura on 25.04.25.
//

import CoreData

final class TrackerRecordStore: NSObject {
    private(set) var context: NSManagedObjectContext
    private(set) var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>?
    
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
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        controller.delegate = delegate
        try? controller.performFetch()
        self.fetchedResultsController = controller
    }
    
    func addRecord(entryId: UUID, date: Date) {
        let record = TrackerRecordCoreData(context: context)
        record.trackerId = entryId
        record.date = date
        try? context.save()
        try? fetchedResultsController?.performFetch()
    }
    
    func fetchRecords(for entryId: UUID) -> [TrackerRecord] {
        try? fetchedResultsController?.performFetch()
        
        return fetchedResultsController?.fetchedObjects?.compactMap { coreData in
            guard let coreDataEntryId = coreData.trackerId,
                  let date = coreData.date,
                  coreDataEntryId == entryId else {
                return nil
            }
            
            return TrackerRecord(entryId: coreDataEntryId, date: date)
        } ?? []
    }
}
