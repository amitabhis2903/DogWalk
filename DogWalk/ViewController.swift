//
//  ViewController.swift
//  DogWalk
//
//  Created by A on 25/05/19.
//  Copyright © 2019 A. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    
    let identifier: String = "Cell"
    
    var managedContext: NSManagedObjectContext!
    
    var current: Dog?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        
        self.firstFetchallEntitiesFromCoreData()
    }

    @IBAction func add(_ sender: Any) {
        
        // Insert a new Walk entity into Core Data
        
        let walk = Walk(context: managedContext)
        walk.date = NSDate()
        
        // Insert the new Walk into the Dog's walks set
        
        if let dog = current,
            let walks = dog.walks?.mutableCopy() as? NSMutableOrderedSet {
            walks.add(walk)
            dog.walks = walks
        }
        
        // Save the managed object context
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Save error: \(error), description: \(error.userInfo)")
        }
        
        // Reload table view
        
        tableView.reloadData()
    }
    
    
    func firstFetchallEntitiesFromCoreData() {
        let dogName = "Fido"
        let dogFetch: NSFetchRequest<Dog> = Dog.fetchRequest()
        dogFetch.predicate = NSPredicate(format: "%K == %@", #keyPath(Dog.name), dogName)
        
        
        do {
            let result = try managedContext.fetch(dogFetch)
            if result.count > 0 {
                // Fido found, use Fido
                current = result.first
            } else {
                current = Dog(context: managedContext)
                current?.name = dogName
                try managedContext.save()
            }
        }catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
    }
    
}


extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return current?.walks?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as UITableViewCell
        
        guard let walk = current?.walks?[indexPath.row] as? Walk, let walkDate = walk.date as Date?
        else {
            return cell
        }
        
        cell.textLabel?.text = dateFormatter.string(from: walkDate)
        return cell
    }
}


extension ViewController: UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "List of walks"
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        
        //1. First, you get a reference to the walk you want to delete.
        
        guard let walkToRemove = current?.walks?[indexPath.row] as? Walk,
            editingStyle == .delete else {
                return
        }
        
        /*Remove the walk from Core Data by calling NSManagedObjectContext’s delete()
        method. Core Data also takes care of removing the deleted walk from the current
        dog’s walks relationship.*/
        
        managedContext.delete(walkToRemove)
        
        /*No changes are final until you save your managed object context — not even
        deletions!*/
        
        do {
            try managedContext.save()
            
            /* Finally, if the save operation succeeds, you animate the table view to tell the user
             about the deletion. */
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch let error as NSError {
            print("Saving error: \(error), description: \(error.userInfo)")
        }
    }
    
    
}
