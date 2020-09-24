//
//  TutorialViewController.swift
//  MobileApp16
//
//  Created by Ilaria Carlini on 12/01/17.
//
//

import UIKit

class TutorialViewController: UIViewController {
    
    // hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    let soundController = SoundController.sharedInstance
    
    var isHumanVsComputer: Bool?
    var AIPlayer: AIPlayer?
    var whitePlayer: String = ""
    var blackPlayer: String = ""
    var unhideElements: [UIImageView]?
    var singleTap: UIGestureRecognizer!
    var counterAnimationTutorial = 0
    var isAnimated = false
    
    @IBOutlet var viewImage: UIView!
    
    /// Initializing all the variables that compose the slides of the tutorial
    override func viewDidLoad() {
        super.viewDidLoad()
        singleTap = UITapGestureRecognizer(target: self, action: #selector(self.tapped(_:)))
        
        
        unhideElements = [backgroundBoard, specialCell1, specialCell2, specialCell3, specialCell4, luke, vader, pilot, chube, empireSymbolPilot, empireSymbolVader, rebelSymbolChube, rebelSymbolLuke, selectedCell]
        
        viewImage.addGestureRecognizer(singleTap)

        // Start
        self.playButton.alpha = 1
        
        tutorialTitle.alpha = 0
        tapToSkip.alpha = 0
        introOfBattleground.alpha = 0
        gameRules.alpha = 0
        boardStructured.alpha = 0
        
        // Animation current turn information
        backgroundInformationView.alpha = 0.1
        turnImageView.alpha = 0.1
        playerNameLabel.alpha = 0.1
        arrowCurrentTurn.alpha = 0
        currentTurn.alpha = 0
        
        // Information about the game
        arrowYourVictoryProgress.alpha = 0
        yourVictoryProgress.alpha = 0
        firstCoin.alpha = 0.1
        secondCoin.alpha = 0.1
        thirdCoin.alpha = 0.1
        specialCellsLabel.alpha = 0.1
        killedEnemiesLabel.alpha = 0.1
        killedEnemiesNumber.alpha = 0.1
        
        // Mage
        mageTutorialText.alpha = 0
        backgroundSpellView.alpha = 0.1
        mageView.alpha = 0.1
        
        // Spell
        healView.alpha = 0.1
        healLabel.alpha = 0.1
        healTutorialText.alpha = 0.0
        
        shockView.alpha = 0.1
        shockLabel.alpha = 0.1
        shockTutorialText.alpha = 0
        
        teleportView.alpha = 0.1
        teleportLabel.alpha = 0.1
        teleportTutorialText.alpha = 0
        
        reviveView.alpha = 0.1
        reviveLabel.alpha = 0.1
        reviveTutorialText.alpha = 0
        raccomandationSpell.alpha = 0
        
        // Dead
        backgroundDeadView.alpha = 0.1
        firstDead.alpha = 0.1
        secondDead.alpha = 0.1
        thirdDead.alpha = 0.1
        fourthDead.alpha = 0.1
        fifthDead.alpha = 0.1
        sixthDead.alpha = 0.1
        seventhDead.alpha = 0.1
        eighthDead.alpha = 0.1
        graveyardTutorialText.alpha = 0
        arrowGraveyard.alpha = 0
        
        // Board
        backgroundBoard.alpha = 0.1
        specialCell1.alpha = 0.1
        specialCell2.alpha = 0.1
        specialCell3.alpha = 0.1
        specialCell4.alpha = 0.1
        arrow1SpecialCell.alpha = 0
        arrow2SpecialCell.alpha = 0
        arrow3SpecialCell.alpha = 0
        arrow4SpecialCell.alpha = 0
        specialCellTutorialText.alpha = 0
        
        // Pieces with background
        chube.alpha = 0
        luke.alpha = 0
        vader.alpha = 0
        pilot.alpha = 0
        rebelSymbolChube.alpha = 0
        rebelSymbolLuke.alpha = 0
        empireSymbolPilot.alpha = 0
        empireSymbolVader.alpha = 0
        lightSideBackgroundTutorialText.alpha = 0
        darkSideBackgroundTutorialText.alpha = 0
        arrowLightSideDescription.alpha = 0
        arrowDarkSideDescription.alpha = 0
        
        // Ciube possible actions
        greenCell1.alpha = 0
        greenCell2.alpha = 0
        greenCell3.alpha = 0
        greenCell4.alpha = 0
        greenCell5.alpha = 0
        greenCell6.alpha = 0
        orangeCell.alpha = 0
        redCell.alpha = 0
        selectedCell.alpha = 0
        chubePossibleActions.alpha = 0
        arrowChubePossibleAction.alpha = 0
        
        // Cell typology description
        greenCellTT.alpha = 0
        orangeCellTT.alpha = 0
        redCellTT.alpha = 0
        possibleActionTitle.alpha = 0
        cellDescriptionTutorialText.alpha = 0
        cellDescriptionTutorialText2.alpha = 0
        cellDescriptionTutorialText3.alpha = 0
        
        // popup attack combat
        popup.alpha = 0
        popupA.alpha = 0
        popupC.alpha = 0
        arrowACombat.alpha = 0
        arrowCCombat.alpha = 0
        popupAttack.alpha = 0
        popupCombat.alpha = 0
        
        // description attack and combat
        attackImageTT.alpha = 0
        attackTitleTT.alpha = 0
        attackCombatDescriptionTT.alpha = 0
        combatTitleTT.alpha = 0
        combatImageTT.alpha = 0
        combatDescription.alpha = 0
        
        // End of game
        specialRulesText.alpha = 0
        specialRulesTitle.alpha = 0
        endOfGameTitle.alpha = 0
        winRules.alpha = 0
        playersName.alpha = 0.1
        letsPlay.alpha = 0
        finalPlayBtn.isHidden = true
        
        if whitePlayer != "" && blackPlayer != "" {
            btnHome.isHidden = true
        } else {
            playButton.isHidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /// At the appear of the first slide of tutorial, set the first title and the 'tap to continue' images.
    override func viewDidAppear(_ animated: Bool) {
        tutorialTitle.alpha = 0
        isAnimated = true
        UIView.animate(withDuration: 2, animations: {
            self.tutorialTitle.alpha = 1
        }) { (success) in
            self.tutorialTitle.alpha = 1
            
            self.isAnimated = false
            
            // in loop
            self.tapToSkip.alpha = 0
                
            UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .autoreverse], animations: {
                self.tapToSkip.alpha = 1
            }, completion: nil)
            // fine loop
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tutorialToGameViewSegue",
            let viewController = segue.destination as? ViewController {
            if let isHumanVsComputer = isHumanVsComputer,
                let AIPlayer = AIPlayer {
                viewController.isHumanVsComputer = isHumanVsComputer
                viewController.AIPlayer = AIPlayer
            }
            viewController.whitePlayer = whitePlayer
            viewController.blackPlayer = blackPlayer
        }
    }
    
    
    @IBOutlet weak var btnHome: UIButton!
    @IBOutlet weak var backgroundBlackView: UIImageView!
    
    // Spell declaration
    @IBOutlet weak var backgroundSpellView: UIImageView!
    @IBOutlet weak var mageView: UIImageView!
    @IBOutlet weak var healView: UIImageView!
    @IBOutlet weak var shockView: UIImageView!
    @IBOutlet weak var teleportView: UIImageView!
    @IBOutlet weak var reviveView: UIImageView!
    @IBOutlet weak var healLabel: UILabel!
    @IBOutlet weak var shockLabel: UILabel!
    @IBOutlet weak var teleportLabel: UILabel!
    @IBOutlet weak var reviveLabel: UILabel!
    
    
    // Dead pieces declaration
    @IBOutlet weak var backgroundDeadView: UIImageView!
    @IBOutlet weak var firstDead: UIImageView!
    @IBOutlet weak var secondDead: UIImageView!
    @IBOutlet weak var thirdDead: UIImageView!
    @IBOutlet weak var fourthDead: UIImageView!
    @IBOutlet weak var fifthDead: UIImageView!
    @IBOutlet weak var sixthDead: UIImageView!
    @IBOutlet weak var seventhDead: UIImageView!
    @IBOutlet weak var eighthDead: UIImageView!
    @IBOutlet weak var playersName: UILabel!
    
    // Turn information
    @IBOutlet weak var turnImageView: UIImageView!
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var specialCellsLabel: UILabel!
    @IBOutlet weak var killedEnemiesLabel: UILabel!
    @IBOutlet weak var firstCoin: UIImageView!
    @IBOutlet weak var secondCoin: UIImageView!
    @IBOutlet weak var thirdCoin: UIImageView!
    @IBOutlet weak var killedEnemiesNumber: UILabel!
    @IBOutlet weak var backgroundInformationView: UIImageView!
    
    // Board
    @IBOutlet weak var backgroundBoard: UIImageView!
    @IBOutlet weak var specialCell1: UIImageView!
    @IBOutlet weak var specialCell2: UIImageView!
    @IBOutlet weak var specialCell3: UIImageView!
    @IBOutlet weak var specialCell4: UIImageView!
    @IBOutlet weak var specialCellTutorialText: UITextView!
    @IBOutlet weak var greenCell1: UIImageView!
    @IBOutlet weak var greenCell2: UIImageView!
    @IBOutlet weak var greenCell3: UIImageView!
    @IBOutlet weak var greenCell4: UIImageView!
    @IBOutlet weak var greenCell5: UIImageView!
    @IBOutlet weak var greenCell6: UIImageView!
    @IBOutlet weak var redCell: UIImageView!
    @IBOutlet weak var chube: UIImageView!
    @IBOutlet weak var orangeCell: UIImageView!
    @IBOutlet weak var luke: UIImageView!
    @IBOutlet weak var pilot: UIImageView!
    @IBOutlet weak var vader: UIImageView!
    @IBOutlet weak var rebelSymbolChube: UIImageView!
    @IBOutlet weak var empireSymbolVader: UIImageView!
    @IBOutlet weak var empireSymbolPilot: UIImageView!
    @IBOutlet weak var rebelSymbolLuke: UIImageView!
    @IBOutlet weak var selectedCell: UIImageView!
    @IBOutlet weak var popup: UIImageView!
    @IBOutlet weak var popupA: UIImageView!
    @IBOutlet weak var popupC: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var boardStructured: UITextView!
    
    // Start declaration
    @IBOutlet weak var tutorialTitle: UILabel!
    @IBOutlet weak var tapToSkip: UILabel!
    @IBOutlet weak var introOfBattleground: UITextView!
    @IBOutlet weak var gameRules: UITextView!
    @IBOutlet weak var arrowCurrentTurn: UIImageView!
    @IBOutlet weak var currentTurn: UITextView!
    @IBOutlet weak var yourVictoryProgress: UITextView!
    @IBOutlet weak var arrowYourVictoryProgress: UIImageView!
    @IBOutlet weak var mageTutorialText: UITextView!
    @IBOutlet weak var healTutorialText: UITextView!
    @IBOutlet weak var shockTutorialText: UITextView!
    @IBOutlet weak var teleportTutorialText: UITextView!
    @IBOutlet weak var reviveTutorialText: UITextView!
    @IBOutlet weak var raccomandationSpell: UITextView!
    @IBOutlet weak var graveyardTutorialText: UITextView!
    @IBOutlet weak var arrowGraveyard: UIImageView!
    @IBOutlet weak var arrow1SpecialCell: UIImageView!
    @IBOutlet weak var arrow2SpecialCell: UIImageView!
    @IBOutlet weak var arrow3SpecialCell: UIImageView!
    @IBOutlet weak var arrow4SpecialCell: UIImageView!
    @IBOutlet weak var lightSideBackgroundTutorialText: UITextView!
    @IBOutlet weak var arrowLightSideDescription: UIImageView!
    @IBOutlet weak var darkSideBackgroundTutorialText: UITextView!
    @IBOutlet weak var arrowDarkSideDescription: UIImageView!
    @IBOutlet weak var chubePossibleActions: UITextView!
    @IBOutlet weak var arrowChubePossibleAction: UIImageView!
    @IBOutlet weak var possibleActionTitle: UITextView!
    @IBOutlet weak var cellDescriptionTutorialText: UITextView!
    @IBOutlet weak var cellDescriptionTutorialText2: UITextView!
    @IBOutlet weak var cellDescriptionTutorialText3: UITextView!
    @IBOutlet weak var greenCellTT: UIImageView!
    @IBOutlet weak var redCellTT: UIImageView!
    @IBOutlet weak var orangeCellTT: UIImageView!
    @IBOutlet weak var popupAttack: UITextView!
    @IBOutlet weak var popupCombat: UITextView!
    @IBOutlet weak var arrowACombat: UIImageView!
    @IBOutlet weak var arrowCCombat: UIImageView!
    @IBOutlet weak var attackTitleTT: UITextView!
    @IBOutlet weak var attackImageTT: UIImageView!
    @IBOutlet weak var combatImageTT: UIImageView!
    @IBOutlet weak var combatTitleTT: UITextView!
    @IBOutlet weak var attackCombatDescriptionTT: UITextView!
    @IBOutlet weak var specialRulesTitle: UITextView!
    @IBOutlet weak var specialRulesText: UITextView!
    @IBOutlet weak var endOfGameTitle: UITextView!

    @IBOutlet weak var winRules: UITextView!
    @IBOutlet weak var combatDescription: UITextView!
    @IBOutlet weak var letsPlay: UILabel!
    @IBOutlet weak var finalPlayBtn: UIButton!
    
    
    @IBAction func playGameAction(_ sender: UIButton) {
        soundController.playEffect(effect: .select)
        performSegue(withIdentifier: "tutorialToGameViewSegue", sender: self)
    }
    
    @IBAction func btnHomePressed(_ sender: UIButton) {
        soundController.playEffect(effect: .back)
    }
    
    /// Recognize the user tap on the view and visualize the animations.
    func tapped(_ sender: UITapGestureRecognizer) {
        
        if isAnimated == false {
            // action on tap
            counterAnimationTutorial += 1
            
            switch counterAnimationTutorial {
                
            case 1:
                // remove the skip element
                hideElements(images: nil, labels: [tutorialTitle, tapToSkip], textViews: nil)
                // game intro
                showPersistent(images: nil, labels: nil, textViews: [introOfBattleground])
            case 2:
                hideElements(images: nil, labels: nil, textViews: [introOfBattleground])
                showPersistent(images: nil, labels: nil, textViews: [gameRules])
            case 3:
                hideElements(images: nil, labels: nil, textViews: [gameRules])
                // see how the board is structured
                showPersistent(images: nil, labels: nil, textViews: [boardStructured])
            case 4:
                hideElements(images: nil, labels: nil, textViews: [boardStructured])
                // Turn
                showPersistent(images: [turnImageView, arrowCurrentTurn], labels: [playerNameLabel], textViews: [currentTurn])
            case 5:
                blurElements(images: [turnImageView], labels: [playerNameLabel], textViews: nil)
                hideElements(images: [arrowCurrentTurn], labels: nil, textViews: [currentTurn])
                
                // Game information
                showPersistent(images: [arrowYourVictoryProgress, firstCoin, secondCoin, thirdCoin
                    ], labels: [specialCellsLabel, killedEnemiesLabel, killedEnemiesNumber], textViews: [yourVictoryProgress])
            case 6:
                blurElements(images: [firstCoin, secondCoin, thirdCoin
                    ], labels: [specialCellsLabel, killedEnemiesLabel, killedEnemiesNumber], textViews: nil)
                hideElements(images: [arrowYourVictoryProgress], labels: nil, textViews: [yourVictoryProgress])
                // Spell: mage
                showPersistent(images: [mageView], labels: nil, textViews: [mageTutorialText])
            case 7:
                blurElements(images: [mageView], labels: nil, textViews: nil)
                hideElements(images: nil, labels: nil, textViews: [mageTutorialText])
                // Spell: heal
                showPersistent(images: [healView], labels: [healLabel], textViews: [healTutorialText])
            case 8:
                blurElements(images: [healView], labels: [healLabel], textViews: nil)
                hideElements(images: nil, labels: nil, textViews: [healTutorialText])
                // Spell: freeze
                showPersistent(images: [shockView], labels: [shockLabel], textViews: [shockTutorialText])
            case 9:
                blurElements(images: [shockView], labels: [shockLabel], textViews: nil)
                hideElements(images: nil, labels: nil, textViews: [shockTutorialText])
                // Spell: teleport
                showPersistent(images: [teleportView], labels: [teleportLabel], textViews:  [teleportTutorialText])
            case 10:
                blurElements(images: [teleportView], labels: [teleportLabel], textViews: nil)
                hideElements(images: nil, labels: nil, textViews: [teleportTutorialText])
                // Spell: revive
                showPersistent(images: [reviveView], labels: [reviveLabel], textViews: [reviveTutorialText])
                
            case 11:
                blurElements(images: [reviveView], labels: [reviveLabel], textViews: nil)
                hideElements(images: nil, labels: nil, textViews: [reviveTutorialText])
                
                showPersistent(images: nil, labels: nil, textViews: [raccomandationSpell])
                
            case 12:
                
                hideElements(images: nil, labels: nil, textViews: [raccomandationSpell])
                // dead pieces
                showPersistent(images: [backgroundDeadView, firstDead, secondDead, thirdDead, fourthDead, fifthDead, sixthDead, seventhDead, eighthDead, arrowGraveyard], labels: nil, textViews: [graveyardTutorialText])
            case 13:
                blurElements(images: [backgroundDeadView, firstDead, secondDead, thirdDead, fourthDead, fifthDead, sixthDead, seventhDead, eighthDead], labels: nil, textViews: nil)
                hideElements(images: [arrowGraveyard], labels: nil, textViews: [graveyardTutorialText])
                // Board
                showPersistent(images: [backgroundBoard, specialCell1, specialCell2, specialCell3, specialCell4, arrow1SpecialCell, arrow2SpecialCell, arrow3SpecialCell, arrow4SpecialCell], labels: nil, textViews: [specialCellTutorialText])
            case 14:
                blurElements(images: [backgroundBoard, specialCell1, specialCell2, specialCell3, specialCell4], labels: nil, textViews: nil)
                hideElements(images: [arrow1SpecialCell, arrow2SpecialCell, arrow3SpecialCell, arrow4SpecialCell], labels: nil, textViews: [specialCellTutorialText])
                // Pieces light side
                showPersistent(images: [chube, luke, rebelSymbolLuke, rebelSymbolChube, arrowLightSideDescription], labels: nil, textViews: [lightSideBackgroundTutorialText])
            case 15:
                blurElements(images: [chube, luke, rebelSymbolLuke, rebelSymbolChube], labels: nil, textViews: nil)
                hideElements(images: [arrowLightSideDescription], labels: nil, textViews: [lightSideBackgroundTutorialText])
                // Pieces dark side
                showPersistent(images: [vader, pilot, empireSymbolVader, empireSymbolPilot, arrowDarkSideDescription], labels: nil, textViews: [darkSideBackgroundTutorialText])
            case 16:
                blurElements(images: [vader, pilot, empireSymbolVader, empireSymbolPilot], labels: nil, textViews:  nil)
                hideElements(images: [arrowDarkSideDescription], labels: nil, textViews: [darkSideBackgroundTutorialText])
                // Show cell background
                showPersistent(images: [greenCell1, greenCell2, greenCell3, greenCell4, greenCell5, greenCell6, orangeCell, redCell, selectedCell, arrowChubePossibleAction], labels: nil, textViews: [chubePossibleActions])
            case 17:
                hideElements(images: [greenCell1, greenCell2, greenCell3, greenCell4, greenCell5, greenCell6, orangeCell, redCell, selectedCell, arrowChubePossibleAction, chube, luke, vader, pilot, empireSymbolPilot, empireSymbolVader, rebelSymbolLuke, rebelSymbolChube, backgroundBoard, specialCell1, specialCell2, specialCell3, specialCell4], labels: nil, textViews: [chubePossibleActions])
                
                // Show cell differences
                showPersistent(images: [greenCellTT, orangeCellTT, redCellTT], labels: nil, textViews: [possibleActionTitle, cellDescriptionTutorialText, cellDescriptionTutorialText2, cellDescriptionTutorialText3])
            case 18:
                hideElements(images: [greenCellTT, orangeCellTT, redCellTT], labels: nil, textViews: [possibleActionTitle, cellDescriptionTutorialText, cellDescriptionTutorialText2,  cellDescriptionTutorialText3])
                
                showPersistent(images: [backgroundBoard, specialCell4, specialCell3, specialCell2, specialCell1, greenCell1, greenCell2, greenCell3, greenCell4, greenCell5, greenCell6, orangeCell, redCell, selectedCell, vader, empireSymbolVader, chube, rebelSymbolChube, popupC, popup, popupA, arrowCCombat, arrowACombat], labels: nil, textViews: [popupCombat, popupAttack])
            case 19:
                hideElements(images: [backgroundBoard, greenCell1, greenCell2, greenCell3, greenCell4, greenCell5, greenCell6, orangeCell, redCell, selectedCell, vader, empireSymbolVader, chube, rebelSymbolChube, popupC, popup, popupA, arrowCCombat, arrowACombat], labels: nil, textViews: [popupCombat, popupAttack])
                showPersistent(images: [attackImageTT, combatImageTT], labels: nil, textViews: [attackCombatDescriptionTT, attackTitleTT, combatDescription, combatTitleTT])
                
            case 20:
                hideElements(images: [attackImageTT, combatImageTT], labels: nil, textViews: [attackCombatDescriptionTT, combatDescription, attackTitleTT, combatTitleTT])
                showPersistent(images: nil, labels: nil, textViews: [specialRulesTitle, specialRulesText, endOfGameTitle, winRules])
            case 21:
                hideElements(images: nil, labels: nil, textViews: [specialRulesTitle, specialRulesText, endOfGameTitle, winRules])
                showPersistent(images: nil, labels: [letsPlay], textViews: nil)
                btnHome.isHidden = true
                playButton.isHidden = true
            case 22:
                // bottone che compare solo se i dati dei player sono gia stati inseriti. altrimenti c'è solo il bottone in alto per tornare alla home
                if whitePlayer != "" && blackPlayer != "" {
                    finalPlayBtn.isHidden = false
                } else {
                    self.dismiss(animated: false, completion: nil)
                }
            default: break
            }
            
            if counterAnimationTutorial <= 23 {
                soundController.playEffect(effect: .select)
            }
        }
    }
    
    func showBtn(btn: UIButton) {
        btn.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            btn.alpha = 0
        }) { (success) in
            btn.alpha = 1
        }
    }
   
    /// Show from alpha 1 to 0
    func hideElements(images: [UIImageView]?, labels: [UILabel]?, textViews: [UITextView]?) {
        isAnimated = true
        
        if let imageViews = images {
            for imageView in imageViews {
                    UIView.animate(withDuration: 1, animations: {
                        imageView.alpha = (imageView == self.backgroundBoard) ? 0.1 : 0
                        imageView.animationDuration = 0.30
                    }) { (success) in
                        imageView.alpha = (imageView == self.backgroundBoard) ? 0.1 : 0
                        self.isAnimated = false
                    }
            }
        }
        if let labels = labels {
            for label in labels {
                UIView.animate(withDuration: 1, animations: {
                    label.alpha = 0
                }) { (success) in
                    label.alpha = 0
                    self.isAnimated = false
                }
            }
        }
        if let textViews = textViews {
            for textView in textViews {
                UIView.animate(withDuration: 1, animations: {
                    textView.alpha = 0
                }) { (success) in
                    textView.alpha = 0
                    self.isAnimated = false
                }
            }
        }
    }

    /// Show from alpha 0.1 to 1
    func showPersistent(images: [UIImageView]?, labels: [UILabel]?, textViews: [UITextView]?) {
        isAnimated = true
        if let imageViews = images {
            for imageView in imageViews {
                UIView.animate(withDuration: 0.5, animations: {
                    imageView.alpha = 1
                    imageView.animationDuration = 0.30
                }) { (success) in
                    imageView.alpha = 1
                    self.isAnimated = false
                }
            }
        }
        
        if let labels = labels {
            for label in labels {
                UIView.animate(withDuration: 0.5, animations: {
                    label.alpha = 1
                }) { (success) in
                    label.alpha = 1
                    self.isAnimated = false
                }
            }
        }
        if let textViews = textViews {
            for textView in textViews {
                UIView.animate(withDuration: 1, animations: {
                    textView.alpha = 1
                }) { (success) in
                    textView.alpha = 1
                    self.isAnimated = false
                }
            }
        }
    }
    
    
    /// Show from alpha 1 to 0.1
    func blurElements(images: [UIImageView]?, labels: [UILabel]?, textViews: [UITextView]?) {
        isAnimated = true
        
        if let imageViews = images {
            for imageView in imageViews {
                if !(unhideElements!.contains(imageView)) {
                    UIView.animate(withDuration: 1, animations: {
                        imageView.alpha = 0.1
                        imageView.animationDuration = 0.30
                    }) { (success) in
                        imageView.alpha = 0.1
                        self.isAnimated = false
                    }
                }
            }
        }
        
        if let labels = labels {
            for label in labels {
                UIView.animate(withDuration: 1, animations: {
                    label.alpha = 0.1
                }) { (success) in
                    label.alpha = 0.1
                    self.isAnimated = false
                }
            }
        }
        
        if let textViews = textViews {
            for textView in textViews {
                UIView.animate(withDuration: 1, animations: {
                    textView.alpha = 0.1
                }) { (success) in
                    textView.alpha = 0.1
                    self.isAnimated = false
                }
            }
        }
    }
    
}
