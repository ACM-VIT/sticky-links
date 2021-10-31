//
//  CategoryViewController.swift
//  Sticky Links
//
//  Created by Samridh Agarwal on 29/09/21.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

	// MARK: Properties
	var categoryArray = [Category]()
    var filteredCategoryData: [Category] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let request : NSFetchRequest<Category> = Category.fetchRequest()
    var searchInProgress: Bool = false

	private var sortType: SortType = .none {
		willSet {
			// If user taps the same options twice the sort will be reversed
			if sortType == newValue {
				categoryArray.reverse()
			} else {
				sortCategories(type: newValue)
			}
			tableView.reloadData()
		}
	}

	// MARK: Subviews
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var outletSwitch: UISwitch!

	private lazy var sortButton: UIBarButtonItem = {
		let byName = UIAction(title: "Name") { [weak self] action in
			self?.sortType = .name
		}
		let byDateCreated = UIAction(title: "Date created") { [weak self] action in
			self?.sortType = .dateCreated
		}
		let menu = UIMenu(title: "Sort by", children: [byName, byDateCreated])
		return UIBarButtonItem(title: "Sort by", image: UIImage(systemName: "arrow.up.arrow.down"), primaryAction: nil, menu: menu)
	}()

    @IBAction func darkAction(_ sender: Any) {
        if outletSwitch.isOn {
            view.window?.overrideUserInterfaceStyle = .dark
            UserDefaults.standard.set(true, forKey: "DarkMode")
        } else {
            view.window?.overrideUserInterfaceStyle = .light
            UserDefaults.standard.set(false, forKey: "DarkMode")
        }
    }

	// MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        navigationItem.rightBarButtonItems?.append(sortButton)
        loadCategory()

        outletSwitch.isOn = UserDefaults.standard.value(forKey: "DarkMode") as? Bool ?? false
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        filteredCategoryData = categoryArray
    }
}



//MARK: Table View Methods

extension CategoryViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchInProgress == true {
            return filteredCategoryData.count
        } else {
            return categoryArray.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        if searchInProgress == true {
            cell.textLabel?.text = filteredCategoryData[indexPath.row].name
        } else {
            cell.textLabel?.text = categoryArray[indexPath.row].name
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "CategorySegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true )
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! LinksViewController
        if searchInProgress == true {
            destinationVC.selectedProperty = filteredCategoryData[tableView.indexPathForSelectedRow!.row]
        } else {
            destinationVC.selectedProperty = categoryArray[tableView.indexPathForSelectedRow!.row]
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteContextualAction(forRowat: indexPath)
        let edit = editContextualAction(forRowat: indexPath)
        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
    
    private func deleteContextualAction(forRowat indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, completionHandler in
			guard let self = self else { return }
            let category = self.searchInProgress ? self.filteredCategoryData[indexPath.row] : self.categoryArray[indexPath.row]
            let name = category.name!
            
            let alert = UIAlertController(title: "Are you sure you want to delete this item?", message: "\(name) will be deleted and can't be retrived afterwards", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
                self.context.delete(category)
                self.categoryArray.removeAll { $0.dateCreated == category.dateCreated }
                self.filterCategories(searchText: self.searchBar.text ?? String())
                self.tableView.reloadData()
                self.saveCategory()
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            completionHandler(true)
        }
        action.image = UIImage(systemName: "trash.fill")

        return action
    }
    
    private func editContextualAction(forRowat indexPath: IndexPath) -> UIContextualAction {
        let category = searchInProgress ? filteredCategoryData[indexPath.row] : categoryArray[indexPath.row]
        let action = UIContextualAction(style: .normal, title: "Edit") { _, _, completionHandler  in
            self.addUpdateCategoryAction(category: category)
            completionHandler(true)
        }
        action.image = UIImage(systemName: "pencil.circle.fill")
        action.backgroundColor = .blue
        return action
    }
}

//MARK: Add Button
extension CategoryViewController{
    
    @IBAction func addButtonPressed(_ sender: Any) {
        addUpdateCategoryAction()
    }
    
    private func addUpdateCategoryAction(category: Category? = nil, message: String = String()) {
        var textField = UITextField()
        let isUpdating = category != nil
        let alert = UIAlertController(title: isUpdating ? "Update Category" : "Add Category", message: "", preferredStyle: .alert)
        
        let attributedString = NSAttributedString(string: message, attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15),
            NSAttributedString.Key.foregroundColor: UIColor.red
        ])
        alert.setValue(attributedString, forKey: "attributedMessage")
        
        let addAction = UIAlertAction(title: isUpdating ? "Update" : "Add", style: .default) { _ in
            self.handleAddCategoryAction(category: category, textField: textField)
        }
        
        alert.addTextField { alertTextField in
            alertTextField.text = category?.name ?? String()
            alertTextField.placeholder = "Enter Category Name"
            textField = alertTextField
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    // Handle of add alertAction
    private func handleAddCategoryAction(category: Category? = nil, textField: UITextField) {
        guard let name = textField.text, !name.isEmpty else {
            addUpdateCategoryAction(category: category, message: "Please enter the category name")
            return
        }
        if let category = category {
            updateCategory(category: category, name: name)
        } else {
            addCategory(name: name)
        }
    }
    
    // Update existing category
    private func updateCategory(category: Category, name: String) {
        let category = category
        category.name = name
        if let index = categoryArray.firstIndex(where: { $0.dateCreated == category.dateCreated }) {
            categoryArray[index] = category
        }
        filterCategories(searchText: searchBar.text ?? String())
        self.sortCategories(type: self.sortType)
        self.saveCategory()
        self.tableView.reloadData()
    }
    
    // Create new category and append in to the list
    private func addCategory(name: String) {
        let newCategory =  Category(context: self.context)
        newCategory.name = name
        newCategory.dateCreated = Date()
        self.categoryArray.append(newCategory)
        self.filteredCategoryData.append(newCategory)
        self.sortCategories(type: self.sortType)
        self.saveCategory()
        self.tableView.reloadData()
    }
    
}

//MARK: BOOKMARK BUTTON
extension CategoryViewController{
    @IBAction func bookmarkCategoryButton(_ sender: UIButton) {
        var linkView = sender.superview
        while let view = linkView, !(view is UITableViewCell) {
            linkView = view.superview
        }
        guard let tableCell = linkView as? UITableViewCell else {return}
        guard let indexPath = tableView.indexPath(for: tableCell) else {return}
        
        let link = self.categoryArray[indexPath.row]
        self.categoryArray.remove(at: indexPath.row)
        self.categoryArray.insert(link, at: 0)
        self.saveCategory()
        self.tableView.reloadData()
    }
    
}

//MARK: SORTING
extension CategoryViewController{
	private func sortCategories(type: SortType) {
		switch type {
		case .none: break
		case .name: categoryArray.sort { $0.name ?? "" < $1.name ?? "" }
		case .dateCreated: categoryArray.sort { $0.dateCreated ?? Date() < $1.dateCreated ?? Date() }
		}
	}
}

//MARK: SEARCH BAR
extension CategoryViewController: UISearchBarDelegate {
        
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchInProgress = true
        searchBar.showsCancelButton = true
        filterCategories(searchText: searchText)
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchInProgress = true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchInProgress = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.tableView.resignFirstResponder()
        self.searchBar.showsCancelButton = false
        tableView.reloadData()
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
}

//MARK: FILTER CATEGORIES
extension CategoryViewController {
    private func filterCategories(searchText: String) {
        filteredCategoryData = searchText.isEmpty ? categoryArray : categoryArray.filter ({ $0.name!.lowercased().contains(searchText.lowercased())})
    }
}

//MARK: Core Data
extension CategoryViewController {
	private func saveCategory() {
        do {
            try context.save()
        } catch {
            print("\(error)")
        }
    }
    
	private func loadCategory() {
        do {
            categoryArray = try context.fetch(request)
            sortCategories(type: sortType)
        } catch {
            print("\(error)")
        }
    }
}
