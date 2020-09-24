//
//  ProfileDetailViewController.swift
//  MobileApp16
//
//  Created by Manan Tariq on 24/12/16.
//
//

import UIKit

class ProfileDetailViewController: UIViewController {

    let soundController = SoundController.sharedInstance
    var playerName: String?
    
    // hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var labelNameUser: UILabel!
    @IBOutlet weak var labelWon: UILabel!
    @IBOutlet weak var labelLost: UILabel!
    @IBOutlet weak var labelDraw: UILabel!
    @IBOutlet weak var labelTotal: UILabel!
    
    @IBOutlet weak var sideImage: UIImageView!
    @IBOutlet weak var percentSide: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let player = CoreDataController.shared.getPlayerByName(playerName!) {
            labelNameUser.text = player.name
            labelWon.text = String(player.win)
            labelLost.text = String(player.lost)
            labelDraw.text = String(player.total - (player.win + player.lost))
            labelTotal.text = String(player.total)
            var whiteSidePercentage: Float = 0
            var darkSidePercentage: Float = 0
            
            let light = Float(player.whiteSide)
            let dark = Float(player.darkSide)
            let total = Float(player.total)
            
            if (player.total >= 1) {
                whiteSidePercentage = light/total * 100
                darkSidePercentage = dark/total * 100
                
                sideImage.image = (whiteSidePercentage >= darkSidePercentage) ? UIImage(named: "rebelsymbol") : UIImage(named: "empiresymbol")
                percentSide.text = (whiteSidePercentage >= darkSidePercentage) ? "\(String(Int(whiteSidePercentage)))% Light Side" : "\(String(Int(darkSidePercentage)))% Dark Side"
            } else {
                sideImage.image = UIImage(named: "LS-Yoda-mage")
                percentSide.text = "Not too many games you have played, yet"
            }
        }
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGesture))
        swipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipe)
    }
    
    func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.right :
            performSegue(withIdentifier: "profileToprofile", sender: self)
            break
        default:
            break
        }
    }

    @IBAction func btnBackPressed(_ sender: UIButton) {
        soundController.playEffect(effect: .select)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
