//
//  ViewController.swift
//  Sticky Links
//
//  Created by Samridh Agarwal on 29/09/21.
//

import UIKit
import CoreData

class LinksViewController: UITableViewController {

	// MARK: Properties
    var links = [Items]()
    var filteredLinksData: [Items] = []
    var searchInProgress: Bool = false
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let request : NSFetchRequest<Items> = Items.fetchRequest()
    var selectedProperty:Category?{
        didSet{
			request.predicate = NSPredicate(format: "parentCategory.name == %@", selectedProperty?.name ?? "")
            loadLink()
        }
    }

	private var sortType: SortType = .none {
		willSet {
			// If user taps the same options twice the sort will be reversed
			if sortType == newValue {
				links.reverse()
			} else {
				sortLinks(type: newValue)
			}
			tableView.reloadData()
		}
	}

	// MARK: Subviews
    @IBOutlet weak var searchBar: UISearchBar!

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

	// MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.primaryBackgroundColor
		navigationItem.rightBarButtonItems?.append(sortButton)
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        filteredLinksData = links
        self.title = selectedProperty?.name
    }
}

//MARK: Table View
extension LinksViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchInProgress == true {
            return filteredLinksData.count
        } else {
            return links.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LinkCell", for: indexPath)
        if searchInProgress == true {
            cell.textLabel?.text = filteredLinksData[indexPath.row].title
        } else {
            cell.textLabel?.text = links[indexPath.row].title
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "OpenLinkSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! WebViewController
        destinationVC.selectedLink = links[tableView.indexPathForSelectedRow!.row]

    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteContextualAction(forRowat: indexPath)
        let edit = editContextualAction(forRowat: indexPath)
        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
    
    private func deleteContextualAction(forRowat indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, completionHandler in
			guard let self = self else { return }
            let link = self.searchInProgress ? self.filteredLinksData[indexPath.row] : self.links[indexPath.row]
            let title = link.title!
            let alert = UIAlertController(title: "Are you sure you want to delete this item?", message: "\(title) will be deleted and can't be retrived afterwards", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
                self.context.delete(link)
                self.links.removeAll { $0.dateCreated == link.dateCreated }
                self.filterLinks(searchText: self.searchBar.text ?? String())
                self.tableView.reloadData()
                self.saveLink()
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            completionHandler(true)
        }
        action.image = UIImage(systemName: "trash.fill")
        return action
    }
    
    private func editContextualAction(forRowat indexPath: IndexPath) -> UIContextualAction {
        let link = searchInProgress ? filteredLinksData[indexPath.row] : links[indexPath.row]
        let action = UIContextualAction(style: .normal, title: "Edit") { _, _, completionHandler  in
            let titleTextField = UITextField()
            let linkTextField = UITextField()
            titleTextField.text = link.title
            linkTextField.text = link.link
            self.addLinkAction(link: link, titleTextField: titleTextField, linkTextField: linkTextField)
            completionHandler(true)
        }
        action.image = UIImage(systemName: "pencil.circle.fill")
        action.backgroundColor = .blue
        return action
    }
    
}

//MARK: Add Links
extension LinksViewController {
    
    @IBAction func addLinks(_ sender: UIBarButtonItem) {
        addLinkAction()
    }
    
    private func addLinkAction(link: Items? = nil, titleTextField: UITextField = UITextField(), linkTextField: UITextField = UITextField(), message: String = String()) {
        let isUpdating = link != nil
        var titleTextField = titleTextField
        var linkTextField = linkTextField
        let alert = UIAlertController(title: isUpdating ? "Update your favourite Webpages" : "Add your favourite Webpages", message: "", preferredStyle: .alert)
        let attributedString = NSAttributedString(string: message, attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15),
            NSAttributedString.Key.foregroundColor: UIColor.red
        ])
        alert.setValue(attributedString, forKey: "attributedMessage")
        let addAction = UIAlertAction(title: isUpdating ? "Update" : "Add", style: .default) { [weak self] (action) in
            guard let self = self else { return }
            self.handleAddLinkAction(link: link, titleTextField: titleTextField, linkTextField: linkTextField)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addTextField { alertTextField in
            alertTextField.text = titleTextField.text
            alertTextField.placeholder = "Enter title for webpage"
            titleTextField = alertTextField
        }
        alert.addTextField { alertTextField in
            alertTextField.text = linkTextField.text
            alertTextField.placeholder = "Enter link for webpage"
            linkTextField = alertTextField
        }
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func handleAddLinkAction(link: Items? = nil, titleTextField: UITextField, linkTextField: UITextField) {
        guard let title = titleTextField.text, let linkAddress = linkTextField.text else { return }
        if title.isEmpty {
            self.addLinkAction(link: link, titleTextField: titleTextField, linkTextField: linkTextField, message: "Please enter title for webpage")
            return
        }
        if linkAddress.isEmpty || !self.isValidUrl(urlString: linkAddress) {
            self.addLinkAction(link: link, titleTextField: titleTextField, linkTextField: linkTextField, message: "Please enter link for webpage")
            return
        }
        if let link = link {
            link.title = title
            link.link = linkAddress
            updateLink(link: link)
        } else {
            addLink(title: title, link: linkAddress)
        }
    }
    
    private func addLink(title: String, link: String) {
        let newLink = Items(context: self.context)
        newLink.title = title
        newLink.link = link
        newLink.parentCategory = self.selectedProperty
        newLink.dateCreated = Date()
        self.links.append(newLink)
        filterLinks(searchText: searchBar.text ?? String())
        self.sortLinks(type: self.sortType)
        self.saveLink()
        self.tableView.reloadData()
    }
    
    private func updateLink(link: Items) {
        if let index = links.firstIndex(where: { $0.dateCreated == link.dateCreated }) {
            links[index] = link
        }
        filterLinks(searchText: searchBar.text ?? String())
        self.sortLinks(type: self.sortType)
        self.saveLink()
        self.tableView.reloadData()
    }
    
}

//MARK: BOOKMARK BUTTON
extension LinksViewController{
    @IBAction func bookmarkLinksButton(_ sender: UIButton) {
    }
}

//MARK: SORTING
extension LinksViewController{
	private func sortLinks(type: SortType) {
		switch type {
		case .none: break
		case .name: links.sort { $0.title ?? "" < $1.title ?? "" }
		case .dateCreated: links.sort { $0.dateCreated ?? Date() < $1.dateCreated ?? Date() }
		}
    }
}

//MARK: SEARCH BAR
extension LinksViewController: UISearchBarDelegate{
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            searchInProgress = true
            searchBar.showsCancelButton = true
            filterLinks(searchText: searchText)
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
            tableView.resignFirstResponder()
            searchBar.showsCancelButton = false
            tableView.reloadData()
        }
        
        func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
            return true
        }
}

//MARK: FILTER CATEGORIES
extension LinksViewController {
    private func filterLinks(searchText: String) {
        filteredLinksData = searchText.isEmpty ? links : links.filter ({ $0.title!.lowercased().contains(searchText.lowercased())})
    }
}


//MARK: Core Data
extension LinksViewController{
    private func saveLink() {
        do {
            try context.save()
        } catch {
            print("\(error)")
        }
    }
    
	private func loadLink() {
        do {
            links = try context.fetch(request)
			sortLinks(type: sortType)
        } catch {
            print("\(error)")
        }
    }
}

//MARK: URL Validation
extension LinksViewController {
    
    func isValidUrl(urlString: String?) -> Bool {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            return false
        }
        return UIApplication.shared.canOpenURL(url)
    }
    
}
