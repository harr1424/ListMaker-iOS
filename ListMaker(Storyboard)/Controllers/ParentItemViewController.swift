//
//  ParentItemViewController.swift
//  ListMaker(Storyboard)
//
//  Created by user on 6/24/22.
//

import UIKit
import RealmSwift

class ParentItemViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var parentItems: Results<ParentItem>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
        
        // support long press
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        tableView.addGestureRecognizer(longPress)
    }
    
    //MARK: - Tableview Datascource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parentItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParentItemCell", for: indexPath)
        cell.textLabel?.text = parentItems?[indexPath.row].name ?? "TODO: Add your first item!"
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // navigate to items
        performSegue(withIdentifier: "ParentToChild", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ChildItemViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.parentItem = parentItems?[indexPath.row]
        }
    }
    
    
    //MARK: - Add new items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var newItemInput = UITextField()
        
        func add() {
            let newItem = ParentItem()
            newItem.name = newItemInput.text!
            save(item: newItem)
        }
        
        
        // In cthe event a new item is an empty string
        let nilItemAlert = UIAlertController(title: "Empty Item", message: "Are you sure you want to add an item with no text? ", preferredStyle: .alert)
        let nilItemActionAffirm = UIAlertAction(title: "Yes", style: .default) { action in
            add()
        }
        let nilItemActionCancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
        nilItemAlert.addAction(nilItemActionAffirm)
        nilItemAlert.addAction(nilItemActionCancel)
        
        let addItemAlert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        let addItemAction = UIAlertAction(title: "Add", style: .default) { action in
            if newItemInput.text != "" {
                add()
            } else {
                self.present(nilItemAlert, animated: true, completion: nil)
            }
        }
        let cancelAddItem = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        addItemAlert.addTextField { (alertTextField) in
            alertTextField.placeholder = "New item..."
            newItemInput = alertTextField
        }
        addItemAlert.addAction(addItemAction)
        addItemAlert.addAction(cancelAddItem)
        present(addItemAlert, animated: true, completion: nil)
    }
    
    //MARK: - Database Methods
    
    func load() {
        parentItems = realm.objects(ParentItem.self)
        tableView.reloadData()
    }
    
    func save(item: ParentItem) {
        do {
            try realm.write {
                realm.add(item)
            }
        } catch {
            print(error)
        }
        self.tableView.reloadData()
    }
    
    func delete(indexPath: IndexPath) {
        if let item = parentItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                }
            } catch {
                print(error)
            }
        }
        load()
    }
    
    func update(indexPath: IndexPath, newName: String) {
        if let item = parentItems?[indexPath.row] {
            do {
                try realm.write {
                    item.name = newName
                }
            } catch {
                print(error)
            }
        }
        load()
    }
    
    //MARK: - Long Press Support Methods
    @objc func longPress(sender: UILongPressGestureRecognizer) {
        var newItemInput = UITextField()
        
        if sender.state == UIGestureRecognizer.State.began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let editItemAlert = UIAlertController(title: "Edit Item", message: "Enter the new name for this item:", preferredStyle: .alert)
                editItemAlert.addTextField { (alertTextField) in
                    alertTextField.placeholder = "New name..."
                    newItemInput = alertTextField
                }
                let removeItemAlert = UIAlertController(title: "Delete Category", message: "Are you sure you want to delete this category?", preferredStyle: .alert)
                let removeItemAction = UIAlertAction(title: "Delete", style: .destructive) { action in
                    self.delete(indexPath: indexPath)
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let editAction = UIAlertAction(title: "Edit", style: .default) { action in
                    self.present(editItemAlert, animated: true) {  }
                }
                let confirmEditAction = UIAlertAction(title: "Save", style: .default) { action in
                    self.update(indexPath: indexPath, newName: newItemInput.text!)
                }
                removeItemAlert.addAction(removeItemAction)
                removeItemAlert.addAction(cancelAction)
                removeItemAlert.addAction(editAction)
                editItemAlert.addAction(cancelAction)
                editItemAlert.addAction(confirmEditAction)
                present(removeItemAlert, animated: true, completion: nil)
            }
        }
    }
}
