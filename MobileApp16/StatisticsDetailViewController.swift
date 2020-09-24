//
//  StatisticsDetailViewController.swift
//  MobileApp16
//
//  Created by Manan Tariq on 03/01/17.
//
//

import UIKit
import CoreData

class StatisticsDetailViewController: UIViewController {

    var matchId: NSManagedObjectID?
    let soundController = SoundController.sharedInstance
    
    // hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var playerLabel: UILabel!
    @IBOutlet weak var turnsLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet weak var winnerImage: UIImageView!
    
    @IBAction func btnBackPressed(_ sender: UIButton) {
        soundController.playEffect(effect: .select)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let match = CoreDataController.shared.getMatchById(matchId!) {
            playerLabel.text = "\(match.playerOne ?? "NA") - \(match.playerTwo ?? "NA")"
            
            turnsLabel.text = String(match.turns)
            
            if let date = match.date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
                dateFormatter.timeZone = TimeZone.current
                dateLabel.text = dateFormatter.string(from: date as Date)
            }
            
            winnerLabel.text = match.winner!
            if match.winner! == match.playerOne! {
                winnerImage.image = UIImage(named: "rebelsymbol.png")
            }else if match.winner! == match.playerTwo! {
                winnerImage.image = UIImage(named: "empiresymbol.png")
            }
        }
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGesture))
        swipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipe)
    }
    
    func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.right :
            performSegue(withIdentifier: "statisticsTostatistics", sender: self)
            break
        default:
            break
        }
    }
}
