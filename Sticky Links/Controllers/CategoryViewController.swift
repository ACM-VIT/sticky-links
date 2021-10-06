//
//  CategoryViewController.swift
//  Sticky Links
//
//  Created by Samridh Agarwal on 29/09/21.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    
    var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let request : NSFetchRequest<Category> = Category.fetchRequest()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var outletSwitch: UISwitch!

    @IBAction func darkAction(_ sender: Any) {
        if outletSwitch.isOn {
            view.window?.overrideUserInterfaceStyle = .dark
            UserDefaults.standard.set(true, forKey: "DarkMode")
        } else {
            view.window?.overrideUserInterfaceStyle = .light
            UserDefaults.standard.set(false, forKey: "DarkMode")
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        loadCategory()

        outletSwitch.isOn = UserDefaults.standard.value(forKey: "DarkMode") as? Bool ?? false
    }
}



//MARK: Table View Methods

extension CategoryViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "CategorySegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true )
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! LinksViewController
        destinationVC.selectedProperty = categoryArray[tableView.indexPathForSelectedRow!.row]
        
        
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteContextualAction(forRowat: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    private func deleteContextualAction(forRowat indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler in
            let name = self.categoryArray[indexPath.row].name!
            let alert = UIAlertController(title: "Are you sure you want to delete this item?", message: "\(name) will be deleted and can't be retrived afterwards", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
                let category = self.categoryArray[indexPath.row]
                self.context.delete(category)
                self.categoryArray.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                self.saveCategory()
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            completionHandler(true)
        }
        action.image = UIImage(systemName: "trash.fill")

        return action
    }
}

//MARK: Add Button
extension CategoryViewController{
    
    @IBAction func addButtonPressed(_ sender: Any) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            let categoryName = Category(context: self.context)
            categoryName.name = textField.text!
            self.categoryArray.append(categoryName)
            self.saveCategory()
        }
        
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Enter Category Name"
            textField = alertTextField
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}

//MARK: BOOKMARK BUTTON
extension CategoryViewController{
    @IBAction func bookmarkCategoryButton(_ sender: UIButton) {
    }
    
}

//MARK: SORTING
extension CategoryViewController{
    @IBAction func sortCategory(_ sender: UIBarButtonItem) {
    }
}

//MARK: SEARCH BAR
extension CategoryViewController{
    
}

//MARK: Helper Fucntions

extension CategoryViewController{
    func saveCategory(){
        do{
            try context.save()
        }
        catch{
            print("\(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategory(){
        do{
            categoryArray = try context.fetch(request)
        }catch{
            print("\(error)")
        }
        tableView.reloadData()
    }
}
