//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController  {
    
    var itemArray = [Item]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //    let defaults = UserDefaults.standard
    //    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        
        
    }
    
    //MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.isDone ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = itemArray[indexPath.row]
        item.isDone = !item.isDone
        
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    @IBAction func AddButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New TodoeyItem", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { alert in
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.isDone = false
            self.itemArray.append(newItem)
            self.saveItems()
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Enter new item"
            textField = alertTextField
            
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    func saveItems () {
        
        do {
            try context.save()
            tableView.reloadData()
        }catch {
            print(error)
        }
    }
    func loadItems(with request : NSFetchRequest<Item> = Item.fetchRequest()) {
        do {
            itemArray = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print("Failed to fetch items: \(error.localizedDescription)")
        }
        //        let decoder = PropertyListDecoder()
        //        do {
        //               let data = try Data(contentsOf: dataFilePath!)
        //            itemArray = try decoder.decode([Item].self, from: data)
        //
        //           } catch {
        //               print("Error loading data: \(error)")
        //           }
    }
    
    
}

// MARK: -UISearchBarDelegate

extension ToDoListViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [ NSSortDescriptor(key: "title", ascending: true)]
        loadItems(with: request)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchBar.text?.count == 0) {
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            loadItems()
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
        loadItems()
    }
}
