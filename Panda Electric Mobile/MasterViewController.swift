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
    let dataSource = MasterViewController.configureDataSource()
    let disposeBag = DisposeBag()
    var isStartUp = true
    static let uiLog = OSLog(subsystem: "com.elbedev.Panda", category: "UI")
    
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
        
        
        guard let url = URL(string: api.socketUrl) else {
            return
        }
        
        pandaConnection = PandaConnection(url: url)
        
        let userId = user()
        
        let channelIdentifier = "sessions:\(userId)"
        let channel = self.pandaConnection.socket().channel(channelIdentifier, payload: ["user": userId as AnyObject])
        let sessionsAPI = PandaSessionAPI(channel: channel, userId: userId)
        
        let loadFavoriteUsers = sessionsAPI
            .sessions()
            .map(TableViewEditingCommand.addSession)
        
        let initialLoadCommand = Observable.just(TableViewEditingCommand.setSessions(sessions: []))
            .concat(loadFavoriteUsers)
            .observeOn(MainScheduler.instance)
        
        let deleteUserCommand = tableView.rx.itemDeleted.map(TableViewEditingCommand.deleteSession)
        
        let moveSessionCommand = tableView
            .rx.itemMoved
            .map(TableViewEditingCommand.moveSession)
        
        let initialState = PandaSessionViewModel(sessions: [])
        
        let viewModel =  Observable.of(initialLoadCommand, deleteUserCommand, moveSessionCommand)
            .merge()
            .scan(initialState) { (viewModel: PandaSessionViewModel, command:TableViewEditingCommand) in viewModel.executeCommand(command) }
            .shareReplay(1)
        
        let _ = viewModel
            .map {
                [
                    SectionModel(model: "Sessions", items: $0.sessions)
                ]
            }
            .bindTo(tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)

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
        guard let uuid = defaults.string(forKey: "uuid") else {
            createUser()
            return
        }
        
        os_log("Signed in as user with uuid %@", log: MasterViewController.uiLog, uuid)
        
        // UserDefaults.standard.removeObject(forKey: "uuid")
        setupConnection(uuid: uuid)
    }
    
    private func createUser() {
        os_log("Creating user", log: MasterViewController.uiLog)
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
    
    func disconnected() {
        self.objects.removeAll()
        self.tableView.reloadData()
    }
    
    private func setupConnection(uuid: String) {
        let _ = pandaConnection.socket().connect().subscribe { (event: Event<SocketConnectivityState>) in
            switch event.element {
            case .Connected?:
                os_log("connected", log: MasterViewController.uiLog, type: .info)
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
}

extension MasterViewController {
    static func configureDataSource() -> RxTableViewSectionedReloadDataSource<SectionModel<String, PandaSessionModel>> {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, PandaSessionModel>>()
        
        dataSource.configureCell = { (_, tv, ip, sessionModel: PandaSessionModel) in
            let cell = tv.dequeueReusableCell(withIdentifier: "PandaSessionTableViewCell")!
            cell.textLabel?.text = sessionModel.title
            return cell
        }
        
        dataSource.titleForHeaderInSection = { dataSource, sectionIndex in
            return dataSource[sectionIndex].model
        }
        
        dataSource.canEditRowAtIndexPath = { (ds, ip) in
            return true
        }
        
        dataSource.canMoveRowAtIndexPath = { _ in
            return true
        }
        
        return dataSource
    }
}

extension MasterViewController: SessionSearchViewControllerDelegate {
    func sessionSearchViewControllerDidFindSession(sessionSearchViewController: SessionSearchViewController, uuid: String) {
        sessionSearchViewController.dismiss(animated: true, completion: { () in
        })
    }
}

