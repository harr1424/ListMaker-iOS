//
//  ChildItemViewController.swift
//  ListMaker(Storyboard)
//
//  Created by user on 6/24/22.
//

import UIKit
import RealmSwift

class ChildItemViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var parentItem: ParentItem? {
        didSet{
            load()
        }
    }
    
    var items: Results<ChildItem>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // support long press
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        tableView.addGestureRecognizer(longPress)
    }
    
    //MARK: - Tableview Datascource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChildItemCell", for: indexPath)
        if let item = items?[indexPath.row] {
            cell.textLabel?.text = item.name
        } else {
            cell.textLabel?.text = "No items added yet"
        }
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    //MARK: - Add new items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var newItemInput = UITextField()
        
        func add() {
            
            if let parentItem = parentItem {
                do {
                    try self.realm.write{
                        let newItem = ChildItem()
                        newItem.name = newItemInput.text!
                        parentItem.childItems.append(newItem)
                    }
                } catch {
                    print(error)
                }
            }
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
                self.tableView.reloadData()
            } else {
                self.present(nilItemAlert, animated: true, completion: nil)
            }
        }
        let cancelAddItem = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        addItemAlert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add an Item"
            newItemInput = alertTextField
        }
        addItemAlert.addAction(addItemAction)
        addItemAlert.addAction(cancelAddItem)
        present(addItemAlert, animated: true, completion: nil)
    }
    
    //MARK: - Database Methods
    
    func load() {
        items = parentItem!.childItems.sorted(byKeyPath: "name", ascending: true)
        tableView.reloadData()
    }
    
    func delete(indexPath: IndexPath) {
        if let item = items?[indexPath.row] {
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
        if let item = items?[indexPath.row] {
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
