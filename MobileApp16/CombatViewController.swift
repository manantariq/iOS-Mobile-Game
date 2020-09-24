//
//  CombatViewController.swift
//  MobileApp16
//
//  Created by Ilaria Carlini on 06/01/17.
//
//

import UIKit

class CombatViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var moveImage: UIImageView!
    @IBOutlet weak var combatDarkImage: UIImageView!
    
    @IBOutlet weak var labelRoundCount: UIImageView!
    
    @IBOutlet weak var combatView: UIImageView!
    
    var player1: String?
    var player2: String?
    
    @IBOutlet weak var player1label: UILabel!
    @IBOutlet weak var player2label: UILabel!
    
    @IBOutlet weak var lifePlayer1label: UILabel!
    @IBOutlet weak var lifePlayer2label: UILabel!
    
    @IBOutlet weak var player1miniature: UIImageView!
    @IBOutlet weak var player2miniature: UIImageView!
    
    @IBOutlet weak var player1pieceNameLabel: UILabel!
    @IBOutlet weak var player2pieceNameLabel: UILabel!
    
    
    var whitePiece: Piece?
    var blackPiece: Piece?
    
    @IBOutlet weak var player1pieceImage: UIImageView!
    @IBOutlet weak var player2pieceImage: UIImageView!
    
    var animationTurn: Color?
    var turnCount: Int?
    var round: Int?
    var moving: Bool?
    var timer: Timer?
    let soundController = SoundController.sharedInstance
    
    override func viewDidLoad() {
        moveImage.isHidden = true
        combatDarkImage.isHidden = true
    }
    
    /// Setting of the attributes of the combat: player's names, pieces involved in the combat and #turn of the combat.
    func setAttributes(_ player1: String, _ player2: String, _ whitePiece: Piece, _ blackPiece: Piece, _ turnCount: Int){
        self.viewDidLoad()
        self.player1 = player1
        self.player2 = player2
        
        if whitePiece.color == .white {
            self.whitePiece = whitePiece
            self.blackPiece = blackPiece
        } else {
            self.blackPiece = whitePiece
            self.whitePiece = blackPiece
        }
        
        self.turnCount = turnCount
        
        self.animationTurn = .white
        self.round = 1
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(CombatViewController.updateView), userInfo: nil, repeats: true)
        self.moving = false
    }
    
    /// Set the labels and the images of the combat in the view.
    func updateView(){
        if !self.moving! && self.turnCount!>=0 {
            player1label.text = player1
            player2label.text = player2
            if let whitePiece = whitePiece, let blackPiece = blackPiece {
                
                player1miniature.image = UIImage(named: (whitePiece.miniature_icon))
                player2miniature.image = UIImage(named: (blackPiece.miniature_icon))
                
                let frontend_namesPiece1 = whitePiece.frontend_name.components(separatedBy: ", ")
                let frontend_namesPiece2 = blackPiece.frontend_name.components(separatedBy: ", ")
                
                player1pieceNameLabel.text = frontend_namesPiece1[1]
                player2pieceNameLabel.text = frontend_namesPiece2[1]
                player1pieceImage.image = UIImage(named: (whitePiece.icon))
                player2pieceImage.image = UIImage(named: (blackPiece.icon))
                
                player1pieceImage.isHidden = false
                player2pieceImage.isHidden = false
                
                let currentLifeWhitePiece = whitePiece.currentVitality + (turnCount!*blackPiece.attack.attackStrength)
                let currentLifeBlackPiece = blackPiece.currentVitality + (turnCount!*whitePiece.attack.attackStrength)
                
                lifePlayer1label.text = (currentLifeWhitePiece > 0) ? "HP: " + String(currentLifeWhitePiece) + "/" + String(whitePiece.initialVitality) : "HP: 0/0"
                lifePlayer2label.text = (currentLifeBlackPiece > 0) ? "HP: " + String(currentLifeBlackPiece) + "/" + String(blackPiece.initialVitality) : "HP: 0/0"
                
                if turnCount! > 0 {
                    animateMovement()
                    turnCount! -= 1
                } else {
                    timer?.invalidate()
                    deadAnimation()
                }
            }
        }
    }
    
    /// Animation of the combat: 1s for the round image, 2s for each attack, 0.5s for the dead animation.
    func animateMovement() {
        self.moving = true
        self.moveImage.image = (animationTurn == .white) ? UIImage(named: "gif-combat-light1") : UIImage(named: "gif-combat-dark1")
        self.labelRoundCount.image = UIImage(named: "label-round\(self.round!)")
        self.labelRoundCount.isHidden = false
        self.round! += 1
        
        // set of the origin point of the UIImage of the round counter
        var roundAnimationOrigin = CGPoint(x: 0.0, y: 0.0)
        roundAnimationOrigin.x = self.combatView.frame.width/2 - self.labelRoundCount.frame.width/2
        roundAnimationOrigin.y = self.combatView.frame.origin.y
        self.labelRoundCount.frame.origin = roundAnimationOrigin
        self.labelRoundCount.isHidden = false
        
        // animation of the round counter
        UIView.animate(withDuration: 1.0, animations: {
            var roundAnimationEnd: CGPoint = CGPoint(x: 0.0, y: 0.0)
            roundAnimationEnd.x = self.combatView.frame.width/2 - self.labelRoundCount.frame.width/2
            roundAnimationEnd.y = self.combatView.frame.height/2
            self.labelRoundCount.frame.origin = CGPoint(x: roundAnimationEnd.x, y: roundAnimationEnd.y)
        }) { (success) in
            self.labelRoundCount.isHidden = true
            
            var combatLightImages: [UIImage] = []
            combatLightImages.append(UIImage(named: "gif-combat-light1")!)
            combatLightImages.append(UIImage(named: "gif-combat-light2")!)
            
            self.moveImage.isHidden = false
            
            // animation of the FIRST combat
            UIView.animate(withDuration: 2.0, animations: {
                // Play Sound
                if let whitePieceName = self.whitePiece?.name {
                    switch whitePieceName {
                    case "Dragon":
                        self.soundController.playEffect(effect: .dragonBlaster)
                    case "Archer":
                        self.soundController.playEffect(effect: .blasterSniper)
                    case "Giant":
                        self.soundController.playEffect(effect: .giantCannon)
                    case "Knight":
                        self.soundController.playEffect(effect: .lightsaber)
                    case "Mage":
                        self.soundController.playEffect(effect: .mageWhite)
                    default:
                        self.soundController.playEffect(effect: .blasterShot)
                    }
                }
                
                self.moveImage.animationImages = combatLightImages
                self.moveImage.animationDuration = 0.30
                self.moveImage.startAnimating()
                self.moveImage.alpha = 0
                
            }) { (success) in
                self.moveImage.alpha = 1
                self.moveImage.stopAnimating()
                // change of the combat turn
                self.setAnimationTurn()
                self.moveImage.isHidden = true
                self.moveImage.image = (self.animationTurn == .white) ? UIImage(named: "gif-combat-light1") : UIImage(named: "gif-combat-dark1")
                
                let combatDarkImages: [UIImage] = [UIImage(named: "gif-combat-dark1")!, UIImage(named: "gif-combat-dark2")!]
                
                self.combatDarkImage.isHidden = false
                
                // animation of the SECOND combat
                UIView.animate(withDuration: 2.0, animations: {
                    // Play Sound
                    if let blackPieceName = self.blackPiece?.name {
                        switch blackPieceName {
                        case "Dragon":
                            self.soundController.playEffect(effect: .dragonBlaster)
                        case "Archer":
                            self.soundController.playEffect(effect: .blasterSniper)
                        case "Giant":
                            self.soundController.playEffect(effect: .giantCannon)
                        case "Knight":
                            self.soundController.playEffect(effect: .lightsaber)
                        case "Mage":
                            self.soundController.playEffect(effect: .mageBlack)
                        default:
                            self.soundController.playEffect(effect: .blasterShot)
                        }
                    }
                    
                    self.combatDarkImage.animationImages = combatDarkImages
                    self.combatDarkImage.animationDuration = 0.30
                    self.combatDarkImage.startAnimating()
                    self.combatDarkImage.alpha = 0
        
                }, completion: { (success) in
                    self.combatDarkImage.alpha = 1
                    
                    self.combatDarkImage.stopAnimating()
                    self.combatDarkImage.isHidden = true
                    self.moving = false
                    self.setAnimationTurn()
                })
            }
        }
    }
    
    /// Animation of the death.
    func deadAnimation() {
        if (whitePiece?.currentVitality)! <= 0 {
            
            // set the origin of the piece
            var whitePieceOrigin = CGPoint(x: 0.0, y: 0.0)
            whitePieceOrigin.x = self.player1pieceImage.frame.origin.x
            whitePieceOrigin.y = self.player1pieceImage.frame.origin.y
            self.player1pieceImage.frame.origin = whitePieceOrigin
            
            // animation of white piece dead
            UIView.animate(withDuration: 0.5, animations: {
                var whitePieceAnimation: CGPoint = CGPoint(x: 0.0, y: 0.0)
                whitePieceAnimation.x = self.player1pieceImage.frame.origin.x
                whitePieceAnimation.y = self.player1pieceImage.frame.origin.y + self.player1pieceImage.frame.height
                self.player1pieceImage.frame.origin = CGPoint(x: whitePieceAnimation.x, y: whitePieceAnimation.y)
                self.player1pieceImage.alpha = 0
            }, completion: { (success) in
                self.player1pieceImage.isHidden = true
                self.player1pieceImage.alpha = 1
                self.player1pieceImage.frame.origin = CGPoint (x: whitePieceOrigin.x, y: whitePieceOrigin.y)
            })
        }
        if (blackPiece?.currentVitality)! <= 0 {
            
            // set the origin of the piece
            var blackPieceOrigin = CGPoint(x: 0.0, y: 0.0)
            blackPieceOrigin.x = self.player2pieceImage.frame.origin.x
            blackPieceOrigin.y = self.player2pieceImage.frame.origin.y
            self.player2pieceImage.frame.origin = blackPieceOrigin
            
            // animation of white piece dead
            UIView.animate(withDuration: 0.5, animations: {
                var blackPieceAnimation: CGPoint = CGPoint(x: 0.0, y: 0.0)
                blackPieceAnimation.x = self.player2pieceImage.frame.origin.x
                blackPieceAnimation.y = self.player2pieceImage.frame.origin.y + self.player2pieceImage.frame.height
                self.player2pieceImage.frame.origin = CGPoint(x: blackPieceAnimation.x, y: blackPieceAnimation.y)
                self.player2pieceImage.alpha = 0
            }, completion: { (success) in
                self.player2pieceImage.isHidden = true
                self.player2pieceImage.alpha = 1
                self.player2pieceImage.frame.origin = CGPoint (x: blackPieceOrigin.x, y: blackPieceOrigin.y)
            })
        }
    }
    
    func setAnimationTurn() {
        self.animationTurn = (self.animationTurn == .white) ? .black : .white
    }
    
}

