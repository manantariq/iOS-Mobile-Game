//
//  WinnerViewController.swift
//  MobileApp16
//
//  Created by Manan Tariq on 04/01/17.
//
//

import UIKit

class WinnerViewController: UIViewController {

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    var image: String?
    var winnerName: String?
    var winnerSide: Color?
    var won: Bool? //true if player won the match otherwise false
        
    let soundController = SoundController.sharedInstance
    
    @IBOutlet weak var winnerImage: UIImageView!
    @IBOutlet weak var winnerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        soundController.stopEndingMusic()
        soundController.playBackgroundMusic()
    }
    
    func setWinnerAttributes(_ imageName: String,_ winnerName: String,_ winnerSide: Color?,_ won: Bool?){
        winnerImage.image = UIImage(named: imageName)
        self.winnerName = winnerName
        self.winnerSide = winnerSide
        self.won = won
        updateView()
    }
    
    
    /// Set the correct view of win/lose/draw with the correct label of text.
    func updateView(){
        
        if let isWon = won {
            if isWon {
                if winnerSide == .white { soundController.playEndingMusic(endingMusic: .victoryRebel) }
                else { soundController.playEndingMusic(endingMusic: .victoryEmpire) }
                winnerLabel.text = (winnerSide == .white) ? "Excellent job, " + winnerName! + "!\nThe balance in the force restored you have.\nIt very powerful is." : "Excellent job, " + winnerName! + "!\nYou have crushed the rebel scum, and you have brought peace in my empire."
            } else {
                if winnerSide == .black { soundController.playEndingMusic(endingMusic: .defeatEmpire) }
                else { soundController.playEndingMusic(endingMusic: .defeatRebel) }
                winnerLabel.text = (winnerSide == .white) ? "Into exile, I must go. \nFailed in training you, " + winnerName! + ", \nI have." : "You have failed me for the last time, " + winnerName! + "!\n"
            }
        } else {
            //Draw
            soundController.playEndingMusic(endingMusic: .draw)
            winnerLabel.text = ""
            winnerLabel.text = "This is not a draw. A new war will begin soon."
        }
    }
}
