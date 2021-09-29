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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        loadCategory()
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
