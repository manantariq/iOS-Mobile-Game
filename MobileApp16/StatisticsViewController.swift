//
//  StatisticsViewController.swift
//  MobileApp16
//
//  Created by Manan Tariq on 31/12/16.
//
//

import UIKit

class StatisticsViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let soundController = SoundController.sharedInstance
    var matches: [MatchStatistic]?
    private var selectedRow: Int?
    @IBOutlet weak var btnDelete: UIButton!
    
    // hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        matches = CoreDataController.shared.getAllMatches()
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGesture))
        swipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipe)
        btnDelete.isHidden = true
    }
    
    func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.right :
            performSegue(withIdentifier: "statisticsTohome", sender: self)
            break
        default:
            break
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        
        guard let matches = matches,
            matches.count > 0 else { return }
        // animate first table row to show delete button
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let pvc = segue.destination as? StatisticsDetailViewController {
            if let row = selectedRow,
                let matches = matches {
                    pvc.matchId = matches[row].objectID
            }
        }
    }
    
    //- MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //player name field
        guard let matches = matches else { return 0 }
        return matches.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "statisticsCell", for: indexPath) as? StatisticsTableViewCell
        
        if let matches = matches {
            cell?.matchLabel.text = "\(matches[indexPath.row].playerOne!) - \(matches[indexPath.row].playerTwo!)"
            if let time = matches[indexPath.row].date {
                cell?.timeLabel.text = timeAgoSince(time as Date)
            }
        }
        return cell!
    }
    
    //- MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        soundController.playEffect(effect: .select)
        selectedRow = indexPath.row
        performSegue(withIdentifier: "statisticsDetailSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            if let matches = self.matches {
                CoreDataController.shared.deleteMatch(matches[indexPath.row].objectID)
            }
            self.matches = CoreDataController.shared.getAllMatches()
            tableView.reloadData()
        })
        deleteAction.backgroundColor = UIColor.clear
        
        return [deleteAction]
    }

    
    @IBAction func btnHomePressed(_ sender: UIButton) {
        soundController.playEffect(effect: .back)
    }
    
    public func timeAgoSince(_ date: Date) -> String {
        
        let calendar = Calendar.current
        let now = Date()
        let unitFlags: NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfYear, .month, .year]
        let components = (calendar as NSCalendar).components(unitFlags, from: date, to: now, options: [])
        
        if let year = components.year, year >= 1 { return "\(year)y ago" }
        if let month = components.month, month >= 1 { return "\(month)M ago" }
        if let week = components.weekOfYear, week >= 1 { return "\(week)w ago" }
        if let day = components.day, day >= 1 { return "\(day)d ago" }
        if let hour = components.hour, hour >= 1 { return "\(hour)h ago" }
        if let minute = components.minute, minute >= 1 { return "\(minute)m ago" }
        if let second = components.second, second >= 3 { return "\(second)s ago" }

        return "Just now"
    }
}
