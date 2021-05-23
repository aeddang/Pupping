//
//  ProfieCoreData.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/05/21.
//

import Foundation
import CoreData

class UserCoreData:PageProtocol {
    static let model = "UserEntity"
    static let defaultId = "me"
    struct Keys {
        static let itemId = "id"
        static let point = "point"
        static let coin = "coin"
        static let mission = "mission"
    }
    
    func me()->User{
        let me = User()
        if let data = getUser() {
            me.setData(data)
        } else {
            self.add(user: me)
        }
        return me
    }
    
    private func getUser()->UserEntity?{
        let container = self.persistentContainer
        do {
            let items = try container.viewContext.fetch(UserEntity.fetchRequest()) as? [UserEntity]
            return items?.first
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
            return nil
        }
    }
    
    private func add(user:User){
        let container = self.persistentContainer
        guard let entity = NSEntityDescription.entity(forEntityName: Self.model, in: container.viewContext) else { return }
        let item = NSManagedObject(entity: entity, insertInto: container.viewContext)
        item.setValue(Self.defaultId, forKey: Keys.itemId)
        item.setValue(user.point, forKey: Keys.point)
        item.setValue(user.coin, forKey: Keys.coin)
        item.setValue(user.mission, forKey: Keys.mission)
    
        self.saveContext()
    }
    
    func update(id:String, data:ModifyUserData){
        let container = self.persistentContainer
        do {
            let fetchRequest:NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == '" + id + "'")
            let objects = try container.viewContext.fetch(fetchRequest)
            for item in objects {
                if let value = data.point { item.setValue(value, forKey: Keys.point) }
                if let value = data.mission { item.setValue(value, forKey: Keys.mission) }
                if let value = data.coin { item.setValue(value, forKey: Keys.coin) }
            }
            self.saveContext()
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
        }
    }
    
    
    
    // MARK: - Core Data stack
    private lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: ApiCoreDataManager.name)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    private func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
