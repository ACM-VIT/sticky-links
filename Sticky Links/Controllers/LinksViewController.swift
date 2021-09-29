//
//  ViewController.swift
//  Sticky Links
//
//  Created by Samridh Agarwal on 29/09/21.
//

import UIKit
import CoreData
class LinksViewController: UITableViewController {
    
    var links=[Items]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let request : NSFetchRequest<Items> = Items.fetchRequest()
    var selectedProperty:Category?{
        didSet{
            loadLink()
        }
    }
  
    @IBOutlet weak var searchBar: UISearchBar!
 
    
//    override func viewWillAppear(_ animated: Bool) {
//
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

//MARK: Table View
extension LinksViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return links.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LinkCell", for: indexPath)
        cell.textLabel?.text = links[indexPath.row].title
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
}

//MARK: Add Links
extension LinksViewController{
    @IBAction func addLinks(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        var linktextField = UITextField()
        let alert = UIAlertController(title: "Add your favourite Webpages", message: "", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            let newLink = Items(context: self.context)
            newLink.title = textField.text!
            newLink.link = linktextField.text!
            newLink.parentCategory = self.selectedProperty
            self.links.append(newLink)
            self.saveLink()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Add title for webpage"
            textField = alertTextField
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Add link for webpage"
            linktextField = alertTextField
        }
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}

//MARK: BOOKMARK BUTTON
extension CategoryViewController{
    @IBAction func bookmarkLinksButton(_ sender: UIButton) {
    }
}

//MARK: SORTING
extension CategoryViewController{
    @IBAction func sortLinksButton(_ sender: UIBarButtonItem) {
    }
}

//MARK: SEARCH BAR
extension CategoryViewController{
    @IBAction func searchButtonPressed(_ sender: UIBarButtonItem) {
        
    }
}


//MARK: Helper Functions
extension LinksViewController{
    func saveLink(){
        do{
            try context.save()
        }
        catch{
            print("\(error)")
        }
        tableView.reloadData()
    }
    
    func loadLink(){
        do{
            links = try context.fetch(request)
        }catch{
            print("\(error)")
        }
        tableView.reloadData()
    }
    
}


