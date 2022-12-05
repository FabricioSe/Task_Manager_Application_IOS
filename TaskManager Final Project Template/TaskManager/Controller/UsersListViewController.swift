//
//  UsersListViewController.swift
//  TaskManager
//
//  Created by Daniel Carvalho on 23/10/22.
//

import UIKit

protocol UsersListViewControllerDelegate {
    
    func userListViewController( selectedUser user : UserModel )
    
}


class UsersListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var delegate : UsersListViewControllerDelegate?

    @IBOutlet var tableView : UITableView!
    @IBOutlet var actBusy : UIActivityIndicatorView!
    @IBOutlet var txtSearchUser : UITextField!
    
    var displayedUsers = [UserModel]()
    
    @IBAction func SearchUser (_sender: Any){
        displayedUsers = []
        let users = DataSource.allUsers
        
        if txtSearchUser.text!.isEmpty {
            displayedUsers = DataSource.allUsers
            tableView.reloadData()
            return
        }
        
        for user in users {
            if user.email.contains(txtSearchUser.text!) || user.name.contains(txtSearchUser.text!) {
                displayedUsers.append(user)
            }
        }
        
        tableView.reloadData()
        
    }
    
    private var busy : Bool = false {
        didSet{
            DispatchQueue.main.async {
                if self.busy {
                    self.actBusy.isHidden = false
                    self.actBusy.startAnimating()
                } else {
                    self.actBusy.isHidden = true
                    self.actBusy.stopAnimating()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        customizeView()
        
        initialize()
        
    }
    
    func initialize() {
        
        displayedUsers = DataSource.allUsers
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // register for the nib
        tableView.register(UINib(nibName: UserTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: UserTableViewCell.identifier)
        
    }

    func customizeView() {
        
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.identifier, for: indexPath) as! UserTableViewCell
        
        //cell.textLabel!.text = DataSource.allUsers[indexPath.row].name.capitalized
        cell.setContent(user: displayedUsers[indexPath.row])
        cell.imgViewStar.image = nil
        if displayedUsers[indexPath.row].uid == Session.loggedUser!.uid {
            //cell.textLabel!.textColor = .blue
            cell.imgViewStar.image = UIImage(systemName: "star.fill")
            cell.imgViewStar.tintColor = UIColor.systemYellow
        }
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedUsers.count
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedUser = displayedUsers[indexPath.row]
        
        if delegate != nil {
            delegate!.userListViewController(selectedUser: selectedUser)
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
}
