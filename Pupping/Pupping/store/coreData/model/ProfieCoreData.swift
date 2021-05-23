//
//  ProfieCoreData.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/05/21.
//

import Foundation
import CoreData

class ProfileCoreData:PageProtocol {
    static let model = "ProfieEntity"
    struct Keys {
        static let itemId = "id"
        static let image = "image"
        static let name = "name"
        static let species = "species"
        static let gender = "gender"
        static let birth = "birth"
        static let lv = "lv"
        static let exp = "exp"
    }
    
    func add(profile:Profile){
        let container = self.persistentContainer
        guard let entity = NSEntityDescription.entity(forEntityName: Self.model, in: container.viewContext) else { return }
        let item = NSManagedObject(entity: entity, insertInto: container.viewContext)
        item.setValue(profile.id, forKey: Keys.itemId)
        if let value = profile.birth { item.setValue(value, forKey: Keys.birth) }
        if let value = profile.gender { item.setValue(value.coreDataKey, forKey: Keys.gender) }
        if let value = profile.nickName { item.setValue(value, forKey: Keys.name) }
        if let value = profile.image { item.setValue(value.pngData() , forKey: Keys.birth) }
        if let value = profile.species { item.setValue(value, forKey: Keys.species) }
        item.setValue(profile.lv, forKey: Keys.lv)
        item.setValue(profile.exp, forKey: Keys.exp)
    
        self.saveContext()
    }

    func remove(id:String){
        let container = self.persistentContainer
        do {
            let fetchRequest:NSFetchRequest<ProfileEntity> = ProfileEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate.init(format: "id = '\(id)'")
            let objects = try container.viewContext.fetch(fetchRequest)
            for obj in objects {
                container.viewContext.delete(obj)
            }
            self.saveContext()
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
        }
    }
    
    func getAllProfiles()->[Profile]{
        let container = self.persistentContainer
        do {
            let items = try container.viewContext.fetch(ProfileEntity.fetchRequest()) as! [ProfileEntity]
            let profiles:[Profile] = items.map{ item in Profile(data: item) }
            return profiles
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
            return []
        }
    }
    
    func update(id:String, data:ModifyProfileData){
        let container = self.persistentContainer
        do {
            let fetchRequest:NSFetchRequest<ProfileEntity> = ProfileEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == '" + id + "'")
            let objects = try container.viewContext.fetch(fetchRequest)
            for item in objects {
                if let value = data.birth { item.setValue(value, forKey: Keys.birth) }
                if let value = data.gender { item.setValue(value.coreDataKey, forKey: Keys.gender) }
                if let value = data.nickName { item.setValue(value, forKey: Keys.name) }
                if let value = data.image { item.setValue(value.pngData() , forKey: Keys.birth) }
                if let value = data.species { item.setValue(value, forKey: Keys.species) }
            }
            self.saveContext()
        } catch {
            DataLog.e(error.localizedDescription, tag: self.tag)
        }
    }
    
    func update(id:String, data:ModifyPlayData){
        let container = self.persistentContainer
        do {
            let fetchRequest:NSFetchRequest<ProfileEntity> = ProfileEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == '" + id + "'")
            let objects = try container.viewContext.fetch(fetchRequest)
            for item in objects {
                item.setValue(data.lv, forKey: Keys.lv)
                item.setValue(data.exp, forKey: Keys.exp)
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
