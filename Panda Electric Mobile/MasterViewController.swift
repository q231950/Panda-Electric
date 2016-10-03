//
//  MasterViewController.swift
//  Panda Electric Mobile
//
//  Created by Martin Kim Dung-Pham on 30/07/16.
//  Copyright © 2016 elbedev.com. All rights reserved.
//

import UIKit
import Panda

class MasterViewController: UITableViewController, PandaConnectionDelegate {

    var detailViewController: DetailViewController? = nil
    var objects = [PandaSession]()
    
    fileprivate var pandaConnection: PandaConnection!
    var sessionChannelHandler: SessionChannelHandler! {
        didSet {
            sessionChannelHandler?.sessionHandler = { (session: PandaSession) -> Void in
                print("handle new session: \(session.identifier)")
                DispatchQueue.main.async {
                    self.objects.insert(session, at: 0)
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.tableView.insertRows(at: [indexPath], with: .automatic)
                }

            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let defaults = UserDefaults.standard
        let uuid = defaults.string(forKey: "uuid")
        guard uuid != nil else {
            createUser(completion: { (user: User?) in
                if let user = user {
                    self.setupConnection(uuid: user.uuid)
                }
            })
            return
        }
        print("Signed in as user with uuid \(uuid)")
//        UserDefaults.standard.removeObject(forKey: "uuid")
        setupConnection(uuid: uuid!)
        
    }
    
    fileprivate func createUser(completion: @escaping (_ user: User?) -> Swift.Void) {
        let alertController = UIAlertController(title: "Create User", message: nil, preferredStyle: .alert)
        let nameAction = UIAlertAction(title: "Ok", style: .default) { (_) in
            let loginTextField = alertController.textFields![0] as UITextField
            print(loginTextField.text)
            if let name = loginTextField.text {
                PandaAPI.createUser(name, completion: { (user: User?, error: Error?) in
                    if let user = user {
                        UserDefaults.standard.setValue(user.uuid, forKey: "uuid")
                        completion(user)
                    } else if let e = error {
                        print(e.localizedDescription)
                    } else {
                        print("[Create User] completion with neither user nor error.")
                    }
                })
            } else {
                self.createUser(completion: completion)
            }
        }
        nameAction.isEnabled = false
        alertController.addTextField(configurationHandler: { (textField: UITextField) in
            textField.placeholder = "Name"
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { (notification) in
                nameAction.isEnabled = textField.text != ""
            }
        })
        alertController.addAction(nameAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action: UIAlertAction) in }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func user() -> String {
        return UserDefaults.standard.string(forKey: "uuid")!
    }

    func insertNewObject(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Create Session", message: nil, preferredStyle: .alert)
        let nameAction = UIAlertAction(title: "Ok", style: .default) { (_) in
            let loginTextField = alertController.textFields![0] as UITextField
            let title = loginTextField.text!
            self.sessionChannelHandler.createSession(self.user(), title: title)
        }
        nameAction.isEnabled = false
        alertController.addTextField(configurationHandler: { (textField: UITextField) in
            textField.placeholder = "Name"
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { (notification) in
                nameAction.isEnabled = textField.text != ""
            }
        })
        alertController.addAction(nameAction)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action: UIAlertAction) in
            
        }))
        
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: PandaConnectionDelegate
    
    func connectionEstablished(_ connection: PandaConnection) {
        print("connectionEstablished")
        
        sessionChannelHandler.requestSessions(user())
        
//        PandaAPI.sessions("phone") { (sessions: [PandaSession]?, err: Error?) in
//            if let s = sessions {
//                DispatchQueue.main.async {
//                    s.forEach({ (session: PandaSession) in
//                        self.objects.insert(session, at: 0)
//                        let indexPath = IndexPath(row: 0, section: 0)
//                        self.tableView.insertRows(at: [indexPath], with: .automatic)
//                    })
//                }
//            }
//        }
    }
    
    func connectionDisconnected(_ connection: PandaConnection) {
        print("socket.onDisconnect")
        objects.removeAll()
        tableView.reloadData()
    }
    
    fileprivate func setupConnection(uuid: String) {
        sessionChannelHandler = SessionChannelHandler(user: uuid,
                                                        channel:"sessions",
                                                        topic:uuid)
        
        //        let url = "https://tranquil-peak-78260.herokuapp.com/socket/websocket"
        let url = "http://localhost:4000/socket/websocket"
        pandaConnection = PandaConnection(url: url, channelHandlers: [sessionChannelHandler])
        pandaConnection.delegate = self
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                let session = objects[(indexPath as NSIndexPath).row]
                controller.channelHandler = EstimationChannelHandler(user: self.user(), channel: session.identifier, topic:session.title)
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = objects[(indexPath as NSIndexPath).row]
        cell.textLabel!.text = object.title
            
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

