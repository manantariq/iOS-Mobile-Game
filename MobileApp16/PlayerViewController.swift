//
//  PlayerViewController.swift
//  MobileApp16
//
//  Created by Manan Tariq on 14/12/16.
//
//

import UIKit

class PlayerViewController: UIViewController {
    
    let soundController = SoundController.sharedInstance
    
    let firstPlayerPickerView: UIPickerView = UIPickerView()
    let secondPlayerPickerView: UIPickerView = UIPickerView()
    var firstSymbol: String = ""
    var secondSymbol: String = ""
    var isMultiplayer: Bool = true
    var players: [PlayerStatistic]?
    
    let AILevels = ["Padawan AI", "Jedi AI", "Jedi Master AI"]

    // hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var viewImage: UIImageView!
    @IBOutlet weak var firstPlayer: UITextField!
    @IBOutlet weak var secondPlayer: UITextField!
    @IBOutlet weak var sideFirstPlayer: UIButton!
    @IBOutlet weak var sideSecondPlayer: UIButton!
    @IBOutlet weak var arrowAnimation: UIImageView!
    @IBOutlet weak var addNewPlayer: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var OneTwoPlayerImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // viewImage.image = UIImage(named: "backgroundGame.png")
        
        //side images setting
//        sideFirstPlayer.setImage(UIImage(named: "rebelsymbol")?.withRenderingMode(.alwaysOriginal), for: .normal)
//        sideSecondPlayer.setImage(UIImage(named: "empiresymbol")?.withRenderingMode(.alwaysOriginal), for: .normal)
        setSideImage("rebelsymbol", "empiresymbol", 0)
        sideFirstPlayer.tag = 0
        sideSecondPlayer.tag = 1
        
        players = CoreDataController.shared.getAllPlayers()
        
        let pickerViewBackgroundImage = UIImage(named: "backgroundGameBlur")
        if let bImage = pickerViewBackgroundImage {
            firstPlayerPickerView.backgroundColor = UIColor(patternImage: bImage)
            secondPlayerPickerView.backgroundColor = UIColor(patternImage: bImage)
        }
        firstPlayerPickerView.delegate = self
        secondPlayerPickerView.delegate = self

        firstPlayer.tag = 0
        secondPlayer.tag = 1
        
        errorLabel.isHidden = true
        
        if !isMultiplayer {
            secondPlayer.text = AILevels[0]
            OneTwoPlayerImage.image = UIImage(named: "one-player-label")
        }
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        swipeDown.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeDown)
        
        var images: [UIImage] = []
        for i in 1...18 {
            images.append(UIImage(named: "arrow\(i)")!)
        }
        
        self.arrowAnimation.animationImages = images
        self.arrowAnimation.animationDuration = 3
        self.arrowAnimation.animationRepeatCount = 2
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.arrowAnimation.startAnimating()
    }

    @IBAction func setSide(_ sender: UIButton) {
        
        soundController.playEffect(effect: .changeFaction)
        let senderImage = UIImagePNGRepresentation(sender.currentImage!)
        let rebelsymbol = UIImagePNGRepresentation(UIImage(named: "rebelsymbol")!)
        
        if senderImage == rebelsymbol {
            setSideImage("empiresymbol", "rebelsymbol", sender.tag)
        } else {
            setSideImage("rebelsymbol", "empiresymbol", sender.tag)
        }
    }
    
    func setSideImage(_ firstImage: String,_ secondImage: String,_ tag: Int){
        
        if tag == 0 {
            sideFirstPlayer.setImage(UIImage(named: firstImage)?.withRenderingMode(.alwaysOriginal), for: .normal)
            firstSymbol = firstImage
            
            sideSecondPlayer.setImage(UIImage(named: secondImage)?.withRenderingMode(.alwaysOriginal), for: .normal)
            secondSymbol =  secondImage
            
        } else {
            sideFirstPlayer.setImage(UIImage(named: secondImage)?.withRenderingMode(.alwaysOriginal), for: .normal)
            firstSymbol = secondImage
            
            sideSecondPlayer.setImage(UIImage(named: firstImage)?.withRenderingMode(.alwaysOriginal), for: .normal)
            secondSymbol = firstImage
        }
    }
    
    func editTextField(_ playerPickerView: UIPickerView,_ sender: UITextField,_ tag: Int){
        
        errorLabel.isHidden = true
        playerPickerView.tag = tag
        sender.inputView = playerPickerView
        playerPickerView.selectRow(playerPickerView.selectedRow(inComponent: 0), inComponent: 0, animated: true)
    }
    
    @IBAction func editPlayerTextField(_ sender: UITextField) {
        
        if sender.tag == 0 { // FirstPlayer TextField
            editTextField(firstPlayerPickerView, sender, 0)
        }else { // SecondPlayer TextField
            editTextField(secondPlayerPickerView, sender, 1)
        }
    }
    
    @IBAction func BtnHomePressed(_ sender: UIButton) {
        soundController.playEffect(effect: .back)
    }
    
    @IBAction func addNewPlayer(_ sender: UIButton) {
        
        soundController.playEffect(effect: .select)
        firstPlayer.endEditing(true)
        secondPlayer.endEditing(true)
        
        let alert = UIAlertController(title: "Enter Player Name", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel))
        alert.addTextField { (configurationTextField) in
            
        }
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler:{ (UIAlertAction) in
            
            if let textField = alert.textFields?.first?.text {
                if textField.lengthOfBytes(using: .ascii) > 0 {
                    CoreDataController.shared.addPlayer(name: textField)
                    self.players = CoreDataController.shared.getAllPlayers()
                    
                    if self.firstPlayer.text!.isEmpty {
                        self.firstPlayer.text = textField.capitalized
                    }else if self.secondPlayer.text!.isEmpty {
                        self.secondPlayer.text = textField.capitalized
                    }
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    ///Start the Game
    @IBAction func playGame(_ sender: UIButton) {
        
        soundController.playEffect(effect: .select)
        firstPlayer.endEditing(true)
        secondPlayer.endEditing(true)
        
        guard !self.firstPlayer.text!.isEmpty else {
            errorLabel.text = "Select First Player Name"
            errorLabel.isHidden = false
            return
        }
        guard !self.secondPlayer.text!.isEmpty else {
            errorLabel.text = "Select Second Player Name"
            errorLabel.isHidden = false
            return
        }
        
        guard firstPlayer.text! != secondPlayer.text! else {
            errorLabel.text = "Name of the players must be different"
            errorLabel.isHidden = false
            return
        }
        
        //show tutorial if there is a new player
        if (CoreDataController.shared.getPlayerByName(firstPlayer.text!)!.tutorial || (isMultiplayer && CoreDataController.shared.getPlayerByName(secondPlayer.text!)!.tutorial)) && CoreDataController.shared.getAppSettings()!.tutorial {
            performSegue(withIdentifier: "playerToTutorialSegue", sender: self)
            
            //set false tutorial flags
            CoreDataController.shared.updatePlayerTutorialFlag(firstPlayer.text!, false)
            CoreDataController.shared.updatePlayerTutorialFlag(secondPlayer.text!, false)
            
        }else {
            performSegue(withIdentifier: "playGameSegue", sender: self)
        }
    }
    
    func swipeGesture(_ sender: UISwipeGestureRecognizer) {
    
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.down :
            firstPlayer.endEditing(true)
            secondPlayer.endEditing(true)
            break
        case UISwipeGestureRecognizerDirection.right :
            performSegue(withIdentifier: "playerTohome", sender: self)
            break
        default:
            break
        }
    }
    
    @IBAction func tapGesture(_ sender: UITapGestureRecognizer) {
        firstPlayer.endEditing(true)
        secondPlayer.endEditing(true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        
        if segue.identifier == "playerToTutorialSegue" || segue.identifier == "playGameSegue" {
            
            var AIColor: Color?
            var AIMaxDepth: Int8 = 4    // Default max depth
            var whitePlayer: String?
            var blackPlayer: String?
            
            // If Human VS Computer Game
            if !isMultiplayer {
                AIColor = (secondSymbol == "rebelsymbol") ? Color.white : Color.black
                
                if let index = AILevels.index(of: secondPlayer.text!) {
                    switch index {
                    case 0:
                        AIMaxDepth = 1
                    case 1:
                        AIMaxDepth = 2
                    case 2:
                        AIMaxDepth = 4
                    default:
                        break
                    }
                }
            }
            
            // Setting players names
            if firstSymbol == "rebelsymbol" {
                whitePlayer = firstPlayer.text!
                blackPlayer = secondPlayer.text!
            } else {
                whitePlayer = secondPlayer.text!
                blackPlayer = firstPlayer.text!
            }
            
            if let viewController = segue.destination as? ViewController {
                
                // If Human VS Computer Game
                if !isMultiplayer {
                    viewController.isHumanVsComputer = true
                    // Creating the AI Player Object for ViewController
                    viewController.AIPlayer = AIMiniMaxPlayer(color: AIColor!, maxDepth: AIMaxDepth)
                }
                
                // Setting players names
                viewController.whitePlayer = whitePlayer!
                viewController.blackPlayer = blackPlayer!
                
            }else if let viewController = segue.destination as? TutorialViewController {
                // If Human VS Computer Game
                if !isMultiplayer {
                    viewController.isHumanVsComputer = true
                    // Creating the AI Player Object for ViewController
                    viewController.AIPlayer = AIMiniMaxPlayer(color: AIColor!, maxDepth: AIMaxDepth)
                }
                // Setting players names
                viewController.whitePlayer = whitePlayer!
                viewController.blackPlayer = blackPlayer!
            }
            
            
        }
        
//        if segue.identifier == "playGameSegue",
//            let viewController = segue.destination as? ViewController {
//            
//            // If Human VS Computer Game
//            if !isMultiplayer {
//                viewController.isHumanVsComputer = true
//                let AIColor = (secondSymbol == "rebelsymbol") ? Color.white : Color.black
//                var AIMaxDepth: Int8 = 4    // Default max depth
//                if let index = AILevels.index(of: secondPlayer.text!) {
//                    switch index {
//                    case 0:
//                        AIMaxDepth = 1
//                    case 1:
//                        AIMaxDepth = 2
//                    case 2:
//                        AIMaxDepth = 4
//                    default:
//                        break
//                    }
//                }
//                // Creating the AI Player Object for ViewController
//                viewController.AIPlayer = AIMiniMaxPlayer(color: AIColor, maxDepth: AIMaxDepth)
//            }
//            
//            // Setting players names
//            if firstSymbol == "rebelsymbol" {
//                viewController.whitePlayer = firstPlayer.text!
//                viewController.blackPlayer = secondPlayer.text!
//            } else {
//                viewController.whitePlayer = secondPlayer.text!
//                viewController.blackPlayer = firstPlayer.text!
//            }
//        }
        
        
    }
    
}


extension PlayerViewController: UIPickerViewDelegate {
    
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(pickerView: UIPickerView!) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if isMultiplayer || pickerView == firstPlayerPickerView {
            // Player name field
            guard let players = players else { return 0 }
            return players.count + 1
        } else {
            // AI name field
            return AILevels.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if isMultiplayer || pickerView == firstPlayerPickerView {
            guard row > 0 else { return "Pick Your Name" }
            guard let players = players else { return nil }
            return players[row-1].name
        } else {
            return AILevels[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var title: NSAttributedString? = nil
        
        if isMultiplayer || pickerView == firstPlayerPickerView {
            guard row > 0 else {
                let themeColor = UIColor(red: CGFloat(55/255.0), green: CGFloat(181/255.0), blue: CGFloat(201/255.0), alpha: CGFloat(1.0))
                return NSAttributedString(string: "Pick Your Name", attributes: [NSForegroundColorAttributeName: themeColor])
            }
            guard let players = players else { return nil }
            
            if let text = players[row-1].name {
                title = NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName: UIColor.white])
            }
        } else {
            title = NSAttributedString(string: AILevels[row], attributes: [NSForegroundColorAttributeName: UIColor.white])
        }
        
        return title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        soundController.playEffect(effect: .back)
        
        if isMultiplayer || pickerView == firstPlayerPickerView {
            let player = (pickerView.tag == 0) ? firstPlayer : secondPlayer
            guard row > 0 else {
                player?.text = ""
                return
            }
            if let players = players {
                player?.text = players[row-1].name
            }
        } else {
            secondPlayer.text = AILevels[row]
        }
    }
    
}

