//
//  MasterViewController.swift
//  Panda Electric Mobile
//
//  Created by Martin Kim Dung-Pham on 30/07/16.
//  Copyright © 2016 elbedev.com. All rights reserved.
//

import UIKit
import Panda
import RxSwift
import RxCocoa
import os.log

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [PandaSessionModel]()
    var sessionsObservable: Observable<PandaSessionModel>!
    let api = PandaAPI()
    var isStartUp = true
    static let uiLog = OSLog(subsystem: "com.elbedev.Panda", category: "UI")
    let sessions = Observable.just(PandaSessionModel.all())
    
    private var pandaConnection: PandaConnection!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        tableView.delegate = nil
        tableView.dataSource = nil
        let _ = sessions.bindTo(tableView
            .rx
            .items(cellIdentifier: PandaSessionTableViewCell.Identifier, cellType: PandaSessionTableViewCell.self)) {
                row, session, cell in
                cell.configureWithSession(session: session)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard isStartUp else {
            return
        }
        
        isStartUp = false
        let defaults = UserDefaults.standard
        let uuid = defaults.string(forKey: "uuid")
        guard uuid != nil else {
            createUser()
            return
        }
        print("Signed in as user with uuid \(uuid)")
        // UserDefaults.standard.removeObject(forKey: "uuid")
        setupConnection(uuid: uuid!)
    }
    
    private func createUser() {
        let alertController = UIAlertController(title: "Create User", message: nil, preferredStyle: .alert)
        let nameAction = UIAlertAction(title: "Ok", style: .default) { (_) in
            let loginTextField = alertController.textFields![0] as UITextField
            
            if let name = loginTextField.text {
                let _ = self.api.userWithName(name).subscribe(onNext: { (user: User) in
                    UserDefaults.standard.setValue(user.uuid, forKey: "uuid")
                    self.setupConnection(uuid: user.uuid)
                    }, onError: { (error: Error) in
                        
                    }, onCompleted: {
                        print("Completed")
                }) {
                    print("Disposed")
                }
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
        let alertController = UIAlertController(title: "Create/Join", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Create new", style: .default, handler: { (action: UIAlertAction) in
            self.createSession()
        }))
        alertController.addAction(UIAlertAction(title: "Join existing", style: .default, handler: { (action: UIAlertAction) in
            self.performSegue(withIdentifier: "sessionSearchSegue", sender: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action: UIAlertAction) in
            
        }))
        
        
        present(alertController, animated: true, completion: nil)
    }
    
    func createSession() {
        let alertController = UIAlertController(title: "Create Session", message: nil, preferredStyle: .alert)
        let nameAction = UIAlertAction(title: "Ok", style: .default) { (_) in
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
    
    func connectionEstablished(_ socket: RxSocket) {
        let uuid = user()
        let channelIdentifier = "sessions:\(uuid)"
        let channel = self.pandaConnection.socket().channel(channelIdentifier, payload: ["user": uuid as AnyObject])
        let _ = channel.send(topic: "read:sessions", payload: ["user": uuid as AnyObject]).filter({ (event: ChannelEvent) -> Bool in
            switch event {
                case .event(_): return true
                default: return false
            }
        }).subscribe(onNext: { (event: ChannelEvent) in
            os_log("received sessions", log: MasterViewController.uiLog, type: .info)
        }, onError: { (error: Error) in
            os_log("error receiving sessions", log: MasterViewController.uiLog, type: .error)
        }, onCompleted: {
            os_log("received sessions completed", log: MasterViewController.uiLog, type: .info)
        }, onDisposed: {
            os_log("received sessions disposed", log: MasterViewController.uiLog, type: .info)
        })
        
//        let _ = sessionsObservable.subscribe(onNext: { (session: PandaSessionModel) in
//            DispatchQueue.main.async {
//                self.objects.insert(session, at: 0)
//                let indexPath = IndexPath(row: 0, section: 0)
//                self.tableView.insertRows(at: [indexPath], with: .automatic)
//            }
//            
//            }, onError: { (error: Error) in
//                
//            }, onCompleted: {
//            }) {
//        }
    }
    
    func disconnected() {
        self.objects.removeAll()
        self.tableView.reloadData()
    }
    
    private func setupConnection(uuid: String) {
        pandaConnection = PandaConnection(url: api.socketUrl, channelHandlers: [])
        let _ = pandaConnection.socket().connect().subscribe { (event: Event<SocketConnectivityState>) in
            switch event.element {
                case .Connected?:
                    os_log("connected", log: MasterViewController.uiLog, type: .info)
                    self.connectionEstablished(self.pandaConnection.socket())
                case .Disconnected(_)?:
                    self.disconnected()
                default: break
            }
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                let session = objects[(indexPath as NSIndexPath).row]
                controller.title = session.title
                controller.user = user()
                let estimationChannelHandler = EstimationChannelHandler(user: self.user(), channel: "estimation", topic:session.identifier)
                estimationChannelHandler.title = session.title
                pandaConnection.appendChannelHandler(channelHandler: estimationChannelHandler)
                controller.channelHandler = estimationChannelHandler
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        } else if segue.identifier == "sessionSearchSegue" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! SessionSearchViewController
            controller.delegate = self
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
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}

extension MasterViewController: SessionSearchViewControllerDelegate {
    func sessionSearchViewControllerDidFindSession(sessionSearchViewController: SessionSearchViewController, uuid: String) {
        sessionSearchViewController.dismiss(animated: true, completion: { () in
        })
    }
}

