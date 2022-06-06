//
//  Persistence.swift
//  Shared
//
//  Created by Gustaf Kugelberg on 05/06/2022.
//

import CoreData

extension PlayResultEntity {
    func setup(with result: PlayResult) {
        timestamp = .now
        level = Int16(result.level)
        time = result.time
        missedBox = result.missedBox.map(Int16.init) ?? -1
        elapsed = result.elapsed
    }

    var result: PlayResult {
        .init(level: Int(level),
              time: time,
              missedBox: missedBox == -1 ? nil : Int(missedBox),
              elapsed: elapsed)
    }
}

struct PersistenceController {
    static let shared = PersistenceController()

    func save(result: PlayResult) throws {
        let context = container.viewContext
        let newItem = PlayResultEntity(context: context)
        newItem.setup(with: result)
        try context.save()
    }

    func loadResults() throws -> [PlayResult] {
        try container.viewContext
            .fetch(PlayResultEntity.fetchRequest())
            .map(\.result)
    }

    func resetResults() throws {
        guard let results = try? container.viewContext.fetch(PlayResultEntity.fetchRequest()) else { return }
        for result in results {
            container.viewContext.delete(result)
        }
        try container.viewContext.save()
    }

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = PlayResultEntity(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "GreatApeGame")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
