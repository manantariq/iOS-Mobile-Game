//
//  ProfileViewController.swift
//  MobileApp16
//
//  Created by Manan Tariq on 24/12/16.
//
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    let soundController = SoundController.sharedInstance
    var players: [PlayerStatistic]?
    private var selectedRow: Int?
    @IBOutlet weak var btnDelete: UIButton!
    
    // hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        players = CoreDataController.shared.getAllPlayers()
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGesture))
        swipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipe)
        btnDelete.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        guard let players = players,
            players.count > 0 else { return }
        // animate firs table row to show delete button
        let indexPath = IndexPath(item: 0, section: 0)
        let contentView = tableView.cellForRow(at: indexPath)?.contentView
        let original = contentView?.frame
        var bounceOffset = original
        bounceOffset?.origin.x -= 100
        self.btnDelete.alpha = 0
        self.btnDelete.isHidden = false
   
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            contentView?.frame = bounceOffset!
            self.btnDelete.alpha = 1
        }) { (_) in
            
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: .curveEaseOut, animations: { 
                contentView?.frame = original!
                self.btnDelete.alpha = 0
            }, completion: { (_) in
                self.btnDelete.isHidden = true
            })
        }
    }

    func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.right :
            performSegue(withIdentifier: "profileTohome", sender: self)
            break
        default:
            break
        }
    }
    
    //- MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //player name field
        guard let players = players else { return 0 }
        return players.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as? ProfileTableViewCell

        if let players = players {
            cell?.cellLabel.text = players[indexPath.row].name
            cell?.totalGameWon.text = String(players[indexPath.row].win)
        }
        return cell!
    }
    
    //- MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        soundController.playEffect(effect: .select)
        selectedRow = indexPath.row
        
        performSegue(withIdentifier: "detailsViewSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
        
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            if let players = self.players {
                CoreDataController.shared.deletePlayer(players[indexPath.row].name!)
            }
            self.players = CoreDataController.shared.getAllPlayers()
            tableView.reloadData()
        })
        deleteAction.backgroundColor = UIColor.clear
        
        return [deleteAction]
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let pvc = segue.destination as? ProfileDetailViewController {
            if let row = selectedRow {
                if let players = players {
                    pvc.playerName = players[row].name
                }
            }
        }
    }
    @IBAction func btnHomePressing(_ sender: UIButton) {
        soundController.playEffect(effect: .back)
    }
    
    @IBAction func addNewPlayer(_ sender: UIButton) {
        
        soundController.playEffect(effect: .select)
        let alert = UIAlertController(title: "Enter Player Name", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel))
        alert.addTextField { (configurationTextField) in
            
        }
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler:{ (UIAlertAction) in
            
            if let textField = alert.textFields?.first?.text {
                if textField.lengthOfBytes(using: .ascii) > 0 {
                    CoreDataController.shared.addPlayer(name: textField)
                    self.players = CoreDataController.shared.getAllPlayers()
                    self.tableView.reloadData()
                }
            }
        }))
        self.present(alert, animated: true, completion: {
           
        })
    }
}
