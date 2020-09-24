//
//  HomeViewController.swift
//  MobileApp16
//
//  Created by Ilaria Carlini on 20/12/16.
//
//

import UIKit

class HomeViewController: UIViewController {
    
    let soundController = SoundController.sharedInstance
    var isMultiplayer: Bool = false
    
    @IBOutlet weak var viewImage: UIImageView!
    @IBOutlet weak var btnTwoPlayer: UIButton!
    @IBOutlet weak var btnOnePlayer: UIButton!    
    
    // hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnOnePlayer.tag = 0
        btnTwoPlayer.tag = 1
        viewImage.image = UIImage(named: "backgroundGame.png")
    }

    @IBAction func actionMultiplayer(_ sender: UIButton) {
        
        soundController.playEffect(effect: .select)
        isMultiplayer = (sender.tag == 0) ? false : true
        performSegue(withIdentifier: "playerViewSegue", sender: self)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let playerViewController = segue.destination as? PlayerViewController {
            playerViewController.isMultiplayer = self.isMultiplayer
        }
    }
    
    @IBAction func btnTutorialPressed(_ sender: Any) {
        soundController.playEffect(effect: .select)
    }
    
    @IBAction func btnSettingPressed(_ sender: UIButton) {
        soundController.playEffect(effect: .select)
    }
    
    @IBAction func btnOnlinePressed(_ sender: UIButton) {
        soundController.playEffect(effect: .select)
        
    }
    @IBAction func comeBackHome(_ segue: UIStoryboardSegue) {
        
    }
    @IBAction func btnProfilePressed(_ sender: UIButton) {
        soundController.playEffect(effect: .select)
    }
    @IBAction func btnStatsPressed(_ sender: UIButton) {
        soundController.playEffect(effect: .select)
    }
}
