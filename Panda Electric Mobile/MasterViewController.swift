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
    var estimationChannelHandler: EstimationChannelHandler! {
        didSet {
            estimationChannelHandler?.estimateHandler = { (estimate: Estimate) -> Void in
                print("handle estimation result \(estimate)")
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
        
        setupConnection()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    func insertNewObject(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Create Session", message: nil, preferredStyle: .alert)
        let nameAction = UIAlertAction(title: "Ok", style: .default) { (_) in
            let loginTextField = alertController.textFields![0] as UITextField
            print(loginTextField.text)
            PandaAPI.createSession(loginTextField.text!, user: "phone", completion: { (session: PandaSession?, err: Error?) in
                if let s = session {
                    DispatchQueue.main.async {
                        self.objects.insert(s, at: 0)
                        let indexPath = IndexPath(row: 0, section: 0)
                        self.tableView.insertRows(at: [indexPath], with: .automatic)
                    }
                } else if let e = err {
                    print(e.localizedDescription)
                } else {
                    print("[Create Session] completion with neither session nor error.")
                }
            })
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
        
        PandaAPI.sessions("phone") { (sessions: [PandaSession]?, err: Error?) in
            if let s = sessions {
                DispatchQueue.main.async {
                    s.forEach({ (session: PandaSession) in
                        self.objects.insert(session, at: 0)
                        let indexPath = IndexPath(row: 0, section: 0)
                        self.tableView.insertRows(at: [indexPath], with: .automatic)
                    })
                }
            }
        }
    }
    
    func connectionDisconnected(_ connection: PandaConnection) {
        print("socket.onDisconnect")
        objects.removeAll()
        tableView.reloadData()
    }
    
    fileprivate func setupConnection() {
        let topic = "main"
        let user = "phone"
    
        estimationChannelHandler = EstimationChannelHandler(user: user,
                                                        channel:"session",
                                                        topic:topic)
        
        //        let url = "https://tranquil-peak-78260.herokuapp.com/socket/websocket"
        let url = "http://localhost:4000/socket/websocket"
        pandaConnection = PandaConnection(url: url, channelHandlers: [estimationChannelHandler])
        pandaConnection.delegate = self
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                let session = objects[(indexPath as NSIndexPath).row]
                controller.channelHandler = EstimationChannelHandler(user: "phone", channel: "session", topic:session.title)
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

