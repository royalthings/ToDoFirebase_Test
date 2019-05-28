//
//  TasksViewController.swift
//  TodoFirebase
//
//  Created by Дмитрий Ага on 5/28/19.
//  Copyright © 2019 Дмитрий Ага. All rights reserved.
//

import UIKit
import Firebase

class TasksViewController: UIViewController {

    //MARK: - variable and constants
    var user: User!
    var ref: DatabaseReference!
    var tasks = Array<Task>()
    
    //MARK: - Outlet
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //take current user
        guard let currentUser = Auth.auth().currentUser else { return }
        
        user = User(user: currentUser)
        ref = Database.database().reference(withPath: "users").child(String(user.uid)).child("tasks")
        
        
    }
    
    //MARK: - Actions
    @IBAction func addTapped(_ sender: Any) {
        
        //create alertCantroller
        let alertController = UIAlertController(title: "New Task", message: "Add new task!", preferredStyle: .alert)
        alertController.addTextField()
        let save = UIAlertAction(title: "Save", style: .default) { [weak self]_ in
            guard let textField = alertController.textFields?.first, textField.text != "" else { return }
            
            //create task
            let task = Task(title: textField.text!, userId: (self?.user.uid)!)
            let taskRef = self?.ref.child(task.title.lowercased())
            taskRef?.setValue(task.convertToDictionary())
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(save)
        alertController.addAction(cancel)
        
        present(alertController, animated: true, completion: nil)
    }

    //exit
    @IBAction func signOutTapped(_ sender: Any) {
        //exit from profile
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        dismiss(animated: true, completion: nil)
    }
    
}
//extension UITableView
extension TasksViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.text = "This is cell number \(indexPath.row)"
        cell.textLabel?.textColor = UIColor.white
        return cell
    }
    
    
}
