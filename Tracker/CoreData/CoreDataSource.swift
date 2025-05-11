//
//  CoreDataSource.swift
//  Tracker
//
//  Created by Yura on 22.04.25.
//

import CoreData
import UIKit

final class CoreDataSource {
    private init() {}
    
    static let shared = CoreDataSource()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Не удалось загрузить хранилище: \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
                print("CoreDataSource: Context saved successfully")
            } catch {
                let nserror = error as NSError
                assertionFailure("Ошибка сохранения: \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
