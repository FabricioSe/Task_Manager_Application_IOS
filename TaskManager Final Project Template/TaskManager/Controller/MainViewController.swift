//
//  MainViewController.swift
//  TaskManager
//
//  Created by Daniel Carvalho on 23/10/22.
//

import UIKit

class MainViewController: UIViewController, UsersListViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, TaskInfoViewControllerDelegate {

    @IBOutlet var imgLogo : UIImageView!
    @IBOutlet var btnAdd : UIButton!
    @IBOutlet var btnUserSelection : UILabel!
    @IBOutlet var lblLoggedUserName : UILabel!
    @IBOutlet var actBusy : UIActivityIndicatorView!
    @IBOutlet var tableView : UITableView!

    @IBOutlet weak var segControlTaskFilter: UISegmentedControl!
    
    var displayedTasks = [TaskModel]()
    
    @IBAction func segControlTaskFilterValueChanged(_ sender: UISegmentedControl) {
        
        let filterIndex = segControlTaskFilter.selectedSegmentIndex
        self.displayedTasks = []
        switch filterIndex{
        case 1:
            //Done Tasks
            for task in DataSource.allTasks {
                if task.done == true{
                    self.displayedTasks.append(task)
                }
            }
            break
            
        case 2:
            //Pending Tasks
            for task in DataSource.allTasks {
                if task.done == false{
                    self.displayedTasks.append(task)
                }
            }
            break
            //All Taskss
        default:
            self.displayedTasks = DataSource.allTasks
            break
        }
        
        
        tableView.reloadData()
       
    }
    
    
    
    private var timer = Timer()
    private var timerTimes = 0
    
    var refreshControl = UIRefreshControl()

    
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
        displayedTasks = DataSource.allTasks
        customizeView()
        
        initialize()
    }
    
    func customizeView() {
        
        navigationController?.navigationItem.hidesBackButton = true
        navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.foregroundColor : UIColor.white ]

        UINavigationBar.appearance().backgroundColor = .blue
    
        imgLogo.layer.cornerRadius = Consts.Layout.smallLogoCornerRadious
        btnAdd.layer.cornerRadius = Consts.Layout.smallButtonCornerRadious
        
        btnUserSelection.enableTapGestureRecognizer(target: self, action: #selector(btnUserSelectionTapped(tapGestureRecognizer:)))
        
        
    }
    
    func initialize() {
        
        lblLoggedUserName.text = "Hi \(Session.loggedUser!.name.capitalized)"
        btnUserSelection.text = Session.loggedUser!.name.uppercased()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        refreshControl.addTarget(self, action: #selector(tableRefreshControl), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        
        // register for the nib
        tableView.register(UINib(nibName: TaskTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: TaskTableViewCell.identifier)
        
        // get the current user tasks
        userListViewController(selectedUser: AppContext.selectedUser!)
        
        self.timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector:#selector(self.timeToShake) , userInfo: nil, repeats: true)

        
    }

    @objc func tableRefreshControl(send : UIRefreshControl) {
        
        DispatchQueue.main.async {
            self.userListViewController(selectedUser: AppContext.selectedUser!)
            self.refreshControl.endRefreshing()
        }
        
    }
    
    @objc private func timeToShake(){
       
        if timerTimes == 3 {
            self.timer.invalidate()
            return
        }
        
        DispatchQueue.main.async {

            self.timerTimes += 1
            self.btnUserSelection.shake()
            
        }
        
    }
    
    
    @objc func btnUserSelectionTapped(tapGestureRecognizer : UITapGestureRecognizer) {
        
        if busy {
            return
        }
        
        busy = true
        
        
        TaskAPIUsers.allUsers(token: Session.authorizationToken!) { httpStatusCode, response in
            
            DispatchQueue.main.async {

                self.busy = false
                
                if httpStatusCode == 200 {
                    DataSource.allUsers = AllUsers.decode(json: response)!.allUsers
                    print(DataSource.allUsers)

                    self.performSegue(withIdentifier: Segue.toUsersListViewController, sender: nil)
                    
                } else {

                    self.busy = false
                    Dialog.error(view: self, title: "Ooops! Error code \(httpStatusCode)!", message: "Something went wrong!", okHandler: nil)
                    
                }
    
            }
            
            
        } failHandler: { httpStatusCode, errorMessage in
            
            DispatchQueue.main.async {

                self.busy = false
                Dialog.error(view: self, title: "Ooops! Error code \(httpStatusCode)!", message: errorMessage, okHandler: nil)

            }
            
        }

    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Segue.toUsersListViewController {
            
            (segue.destination as! UsersListViewController).delegate = self
            
        }
        
        if segue.identifier == Segue.toTaskInfoViewControllerAdding {
            
            (segue.destination as! TaskInfoViewController).delegate = self
            
        }

        
    }
    
    
    @IBAction func btnLogOffTapped() {
        
        if busy {
            return
        }
        
        navigationController?.popViewController(animated: true)
        
    }
    
    
    // from delegate
    func userListViewController(selectedUser user: UserModel) {
        
        AppContext.selectedUser = user
        
        busy = true
        

        DispatchQueue.main.async {

            self.btnUserSelection.text = AppContext.selectedUser!.name.uppercased()

            DataSource.allTasks = []
            self.tableView.reloadData()



            if Session.loggedUser!.uid == AppContext.selectedUser!.uid {
                // listing logged user own tasks

                TaskAPITasks.assignedTo(token: Session.authorizationToken!) { httpStatusCode, response in
                    
                    DispatchQueue.main.async {

                        self.busy = false

                        if httpStatusCode == 200 {

                            DataSource.allTasks = AllTasks.decode(json: response)!.allTasks
                            // HERE
                            self.displayedTasks = DataSource.allTasks
                            
                            self.tableView.reloadData()
                            
                        } else {

                            self.busy = false
                            Dialog.error(view: self, title: "Ooops! Error code \(httpStatusCode)!", message: "Something went wrong!", okHandler: nil)
                            
                        }
            
                    }
                    
                } failHandler: { httpStatusCode, errorMessage in
                    
                    DispatchQueue.main.async {

                        self.busy = false
                        Dialog.error(view: self, title: "Ooops! Error code \(httpStatusCode)!", message: errorMessage, okHandler: nil)

                    }
                    
                }
                
                
            } else {
                // listing another users tasks
                TaskAPITasks.createdBy(token: Session.authorizationToken!) { httpStatusCode, response in
                    
                        DispatchQueue.main.async {

                            self.busy = false

                            if httpStatusCode == 200 {
                                
                                let tasks = AllTasks.decode(json: response)!.allTasks
                                // filtering only tasks assigned to selected user
                                
                                for task in tasks {
                                    if task.assignedToUid == AppContext.selectedUser!.uid {
                                        DataSource.allTasks.append(task)
                                    }
                                }
                                // HERE
                                self.displayedTasks = DataSource.allTasks
                                
                                print(DataSource.allTasks)
                                self.tableView.reloadData()
                                
                            } else {

                                self.busy = false
                                Dialog.error(view: self, title: "Ooops! Error code \(httpStatusCode)!", message: "Something went wrong!", okHandler: nil)
                                
                            }
                
                        }
                    
                    
                } failHandler: { httpStatusCode, errorMessage in
                    
                    DispatchQueue.main.async {

                        self.busy = false
                        Dialog.error(view: self, title: "Ooops! Error code \(httpStatusCode)!", message: errorMessage, okHandler: nil)

                    }
                    
                }

                
            }
            

        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.identifier, for: indexPath) as! TaskTableViewCell
        
        //let task = DataSource.allTasks[indexPath.row]
        
        cell.setContent(task: displayedTasks[indexPath.row])
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 130
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let selectedTask = DataSource.allTasks[indexPath.row]
        //let selectedTask = displayedTasks[indexPath.row]
        
        if Session.loggedUser!.uid != selectedTask.createdByUid {
            return nil
        }
        
        if busy {
            return nil
        }
        
        let actDelete = UIContextualAction(style: .normal, title: "") { action, view, complete in

            self.busy = true
            
            TaskAPITasks.deleteTask(token: Session.authorizationToken!, taskUid: selectedTask.taskUid) { httpStatusCode, response in

                DispatchQueue.main.async {

                    if httpStatusCode == 200 {
                    
                        DataSource.allTasks.remove(at: indexPath.row)
                        
                        self.displayedTasks.remove(at: indexPath.row)
                        
                        tableView.deleteRows(at: [indexPath], with: .bottom)

                    }
                    
                    self.busy = false
                    complete(true)

                }
                
            } failHandler: { httpStatusCode, errorMessage in
                
                DispatchQueue.main.async {
                    self.busy = false
                    complete(true)
                }

            }
            
            
        }
        
        actDelete.image = UIImage(systemName: "trash")
        actDelete.backgroundColor = .systemRed
        
        let configuration = UISwipeActionsConfiguration(actions: [actDelete])
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
        
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let selectedTask = displayedTasks[indexPath.row]
        
        if Session.loggedUser!.uid != selectedTask.assignedToUid {
            return nil
        }
        
        if busy {
            return nil
        }
        
        let actDone = UIContextualAction(style: .normal, title: "") { action, view, complete in

            self.busy = true
            
            TaskAPITasks.setTaskDone(token: Session.authorizationToken!, taskUid: selectedTask.taskUid, done: !selectedTask.done) { httpStatusCode, response in

                DispatchQueue.main.async {
                    
                    if httpStatusCode == 200 {
                        DataSource.allTasks[indexPath.row].done = !DataSource.allTasks[indexPath.row].done
                       
                        self.displayedTasks[indexPath.row].done = !self.displayedTasks[indexPath.row].done
                        
                        tableView.reloadRows(at: [indexPath], with: .bottom)
                    }

                    self.busy = false
                    complete(true)
                }


            } failHandler: { httpStatusCode, errorMessage in

                DispatchQueue.main.async {
                    self.busy = false
                    complete(true)
                }

            }
            
        }
        
        if selectedTask.done {
            actDone.image = UIImage(systemName: "xmark")
            actDone.backgroundColor = .orange
        } else {
            actDone.image = UIImage(systemName: "checkmark")
            actDone.backgroundColor = .systemGreen
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [actDone])
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration

    }
    
    // from delegate
    func taskInfoViewController(newTask taskUid: String) {
        
        userListViewController(selectedUser: AppContext.selectedUser!)
        
    }

}

