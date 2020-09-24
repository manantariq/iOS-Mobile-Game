//
//  ViewController.swift
//  MobileApp16
//
//  Created by Alessandro Castiglioni on 31/10/16.
//
//

import UIKit

class ViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    let soundController = SoundController.sharedInstance
    var game = Game()
    var whitePlayer: String = ""
    var blackPlayer: String = ""
    var spellSelected: Spell?
    // Coordinata di destinazione (corrisponde ad un pezzo del nemico)
    var endingCell: CollectionViewCell?
    var startingCell: CollectionViewCell?
    var pieceToRevive: [Coordinate:Coordinate] = [:]
    var combatTurn = 0
    var playerCombatPiece: Piece?
    var opponentCombatPiece: Piece?
    
    var btnMoveAttackTag: Int?
    var blurEffectView: UIView?
    var popView: UIViewController?
    var winnerViewController: WinnerViewController?
    var combatViewController: CombatViewController?
    
    var onlineGameId: String?
    var gameUrl: String?
    var isOnlineGame: Bool = false
    var onlinePlayerColor: Color?
    var userMove: String = ""
    let maxCounter = 30 // timer for user response in online game
    var counter = 0
    var timer = Timer()
    
    var isHumanVsComputer: Bool = false
    var isFirstTurn: Bool = true
    var AIPlayer: AIPlayer!
    var AIMove: String = ""
    
    // GCD
    let AIDispatchQueue = DispatchQueue(label: "it.polimi.StarWarsBattleground.AI_Queue", qos: .userInitiated)
    var AIWorkItem: DispatchWorkItem!
    
    
    // Coordinata associata al primo click (corrisponde ad un pezzo del player corrente)
    var startingCoordinate: Coordinate? {
        didSet {
            updateSelectedPiece(tapped: false, at: oldValue)
            updateSelectedPiece(tapped: true, at: startingCoordinate)
        }
    }
    
    // hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var ErrorLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var combatView: UIView!
    @IBOutlet weak var combatLabel: UIImageView!
    @IBOutlet weak var playersName: UILabel!
    @IBOutlet weak var winnerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var AIActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var moveImage: UIImageView!
    @IBOutlet weak var viewImage: UIImageView!
    @IBOutlet weak var backgroundBoard: UIImageView!
    
    // Dead pieces
    @IBOutlet weak var firstDead: UIImageView!
    @IBOutlet weak var secondDead: UIImageView!
    @IBOutlet weak var thirdDead: UIImageView!
    @IBOutlet weak var fourthDead: UIImageView!
    @IBOutlet weak var fifthDead: UIImageView!
    @IBOutlet weak var sixthDead: UIImageView!
    @IBOutlet weak var seventhDead: UIImageView!
    @IBOutlet weak var eightDead: UIImageView!
    
    // Detail miniature
    @IBOutlet weak var pieceDetailBackground: UIImageView!
    @IBOutlet weak var pieceMiniatureImage: UIImageView!
    @IBOutlet weak var pieceNameLabel: UILabel!
    @IBOutlet weak var pieceTotalLifeLabel: UILabel!
    @IBOutlet weak var pieceAttackStLabel: UILabel!
    @IBOutlet weak var pieceTurnMalusLabel: UILabel!
    @IBOutlet weak var firstAttackDirection: UIImageView!
    @IBOutlet weak var secondAttackDirection: UIImageView!
    @IBOutlet weak var infoTotalLabels: UILabel!
    @IBOutlet weak var infoAttackLabel: UILabel!
    @IBOutlet weak var infoMalusLabel: UILabel!
    @IBOutlet weak var infoAttackDirectionLabel: UILabel!
    
    // Spell declaration
    @IBOutlet weak var btnSpellMage: UIButton!
    @IBOutlet weak var labelHeal: UILabel!
    @IBOutlet weak var labelShock: UILabel!
    @IBOutlet weak var labelTeleport: UILabel!
    @IBOutlet weak var labelRevive: UILabel!
    @IBOutlet weak var selectedSpellHeal: UIImageView!
    @IBOutlet weak var selectedSpellShock: UIImageView!
    @IBOutlet weak var selectedSpellTeleport: UIImageView!
    @IBOutlet weak var selectedSpellRevive: UIImageView!
    @IBOutlet weak var btnSpellHeal: UIButton!
    @IBOutlet weak var btnSpellFreeze: UIButton!
    @IBOutlet weak var btnSpellTeleport: UIButton!
    @IBOutlet weak var btnSpellRevive: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        
        game.startGame(player1: Player(name: whitePlayer, turn: .white, win: 0, draw: 0), player2: Player(name: blackPlayer, turn: .black, win: 0, draw: 0))
        playersName.text = whitePlayer + " - " + blackPlayer
        timerLabel.isHidden = true
        counter = maxCounter
        updateGameBoard()
        viewImage.image = UIImage(named: "backgroundGame.png")
        backgroundBoard.image = UIImage(named: "backgroundBoardWithoutCell.png")
        moveImage.isHidden = true
        showPieceInfoLabel(true)
        setDefaultDeadImages()
        
        blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        blurEffectView?.frame = self.view.frame
        
        combatView.isHidden = true
        winnerView.isHidden = true
        
        btnSpellHeal.tag = 0
        btnSpellFreeze.tag = 1
        btnSpellTeleport.tag = 2
        btnSpellRevive.tag = 3
        
        combatLabel.isHidden = true
        
        ErrorLabel.isHidden = true
        ErrorLabel.text = "You can't cast this spell now."
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Online Game
        if isOnlineGame, game.turn == onlinePlayerColor {
            timerLabel.isHidden = true
            
            getOnlinePlayerMoves()
        }
        // Human VS Computer Game
        if isHumanVsComputer, game.turn == AIPlayer.AIColor, !game.isGameEnded {
            prepareAIMove()
            makeAIMove()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "winnerViewSegue" {
            winnerViewController = segue.destination as? WinnerViewController
        }
        
        if segue.identifier == "combatViewSegue" {
            combatViewController = segue.destination as? CombatViewController
        }
    }
    
    /// Method called after the user tap on a spell element
    func btnSpellAction(_ spell: Spell,_ selectedSpell: UIImageView,_ type: String){ //type = "F","H","T","R"
        deselectHightlightedPieces()
        
        if spellSelected != spell {
            deselectTap()
            spellSelected = spell
            if spell == .revive { reviveDeadPiece() }
            else {
                let cells = game.getAllowedSpellCoordinate(spell: spell)
                if cells.count > 0 {
                    highlightCells(cells: game.getAllowedSpellCoordinate(spell: spell), action: .spell(spell))
                } else { errorLabelAnimation() }
            }
            deselectSpellLabels()
            selectedSpell.isHidden = false
            userMove = "\(type)"
        } else {
            deselectTap()
            deselectSpellLabels()
        }
    }
    
    /// Visualize the error label when the user tap on a spell that he can't perform (heal or revive at the start of a game)
    func errorLabelAnimation() {
        ErrorLabel.alpha = 0
        ErrorLabel.isHidden = false
        
        UIView.animate(withDuration: 0.50, animations: {
            self.ErrorLabel.alpha = 1
        }) { (success) in
            self.ErrorLabel.alpha = 1
            sleep(UInt32(0.7))
            
            UIView.animate(withDuration: 0.50, animations: {
                self.ErrorLabel.alpha = 0
            }) { (success) in
                self.ErrorLabel.alpha = 0
                self.ErrorLabel.isHidden = true
            }
        }
    }
    
    @IBAction func actionSpells(_ sender: UIButton) {
        soundController.playEffect(effect: .back)
        guard game.turn != onlinePlayerColor else { return }
        guard !isHumanVsComputer || game.turn != AIPlayer.AIColor else { return }
        guard combatView.isHidden else { return }
        
        let spell: Spell = (sender.tag == 0) ? .heal : ((sender.tag == 1) ? .freeze : ((sender.tag == 2) ? .teleport : .revive))
        let selectedSpell: UIImageView = (sender.tag == 0) ? selectedSpellHeal : ((sender.tag == 1) ? selectedSpellShock : ((sender.tag == 2) ? selectedSpellTeleport : selectedSpellRevive))
        let spellType = (sender.tag == 0) ? "H" : ((sender.tag == 1) ? "F" : ((sender.tag == 2) ? "T" : "R"))
        btnSpellAction(spell,selectedSpell,spellType)
    }
    
    /// Actions
    @IBAction func cellTapped(_ sender: UITapGestureRecognizer) {
        
        let tapLocation = sender.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: tapLocation) else { return }
        guard let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell else { return }
        
        guard !game.isGameEnded else { return }
        guard combatView.isHidden else { return }
        guard game.turn != onlinePlayerColor else { //if is onlineplayer turn then show only piece information
            if let piece = game.board.getPiece(at: cell.coordinate) {
                showPieceInfoView(piece)
            }
            return
        }
        guard !isHumanVsComputer || game.turn != AIPlayer.AIColor else { return }
        
        if let spell = spellSelected {
            
            guard cell.revivingCell || cell.healingCell || cell.freezingCell || Spell.teleport == spell else {
                deselectTap()
                deselectHightlightedPieces()
                deselectSpellLabels()
                return
            }
            
            // First click after the spell selection
            // The spell is selected: the following tap activate a heal or freeze or revive spell.
            if startingCoordinate == nil, endingCell == nil {
                startingCoordinate = cell.coordinate
                if spell == .heal || spell == .freeze {
                    let _ = doSpellAction(.spell(spell),nil)
                }
                if spell == .revive {
                    let coordinate = pieceToRevive.filter({$0.value == cell.coordinate})
                    if let piece = game.pieces.filter({!$0.isAlive && game.turn == $0.color && $0.initialPosition == coordinate[0].key}).first {
                        let _ = doSpellAction(.spell(.revive), piece)
                    }
                }
            }
            // Second click (case teleport only)
            else if startingCoordinate != nil, endingCell == nil {
                endingCell = cell
                if spell == .teleport {
                    let _ = doSpellAction(.spell(spell),nil)
                }
            }
        } else {
            // First click for move / attack -> The spellSelected variable is not setted
            if startingCoordinate == nil, endingCell == nil {
                
                guard let piece = game.board.getPiece(at: cell.coordinate) else { return }
                guard piece.color == game.turn && !piece.isFrozen else {
                    showPieceInfoView(piece) //selected cell is the opponent cell or piece is frozen
                    return
                }
                performFirstClickAction(cell,piece)
            }
            // Second click for move / attack
            else if startingCoordinate != nil, endingCell == nil {
                
                guard !cell.movingCell && !cell.attackingCell else {
                    endingCell = cell
                    self.secondTapAction(cell: self.endingCell!) // The selected cell is one of the cells in which the user can perform the action
                    return
                }
                guard let piece = game.board.getPiece(at: cell.coordinate)  else { return }
                guard piece.color == game.turn &&  !piece.isFrozen else {
                    showPieceInfoView(piece) //selected cell is the opponent cell or piece is frozen
                    return
                }
                guard startingCoordinate != cell.coordinate else {
                    //if cell is already selected then deselect all allowed moves and attacks cells
                    deselectHightlightedPieces()
                    deselectTap()
                    updateTurnInformationView()
                    return
                }
                performFirstClickAction(cell, piece) //user select an other piece
            }
        }
    }
    
    ///popover move button action
    @IBAction func moveAction(_ segue: UIStoryboardSegue) {
        userMove = "\(userMove)M"
        let _ = doMoveAttackAction(.move)
    }
    ///popover attack button action
    @IBAction func attackAction(_ segue: UIStoryboardSegue) {
        userMove = "\(userMove)A"
        let _ = doMoveAttackAction(.attack)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        deselectHightlightedPieces()
        deselectTap()
        self.blurEffectView?.removeFromSuperview()
    }
    
    func showPopOverView(_ identifire: String,_ width: Int,_ height: Int){
        
        popView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifire)
        
        popView?.modalPresentationStyle = UIModalPresentationStyle.popover
        popView?.preferredContentSize = CGSize(width: width, height: height)
        popView?.popoverPresentationController?.delegate = self
        popView?.popoverPresentationController?.sourceView = self.view
        popView?.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        popView?.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        
        self.view.addSubview(blurEffectView!)
        
        self.present(popView!, animated: true, completion: nil)
        
//        if let pop = popView?.popoverPresentationController,
//            identifire == "winnerView"{ //disable out touch popover
//            popView?.isModalInPopover = true
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                pop.passthroughViews = nil
//            }
//        }
    }
    
    @IBAction func settingAction(_ sender: UIButton) {
        // MARK: play sound call
        soundController.playEffect(effect: .select)
        showPopOverView("optionView", 300, 220)
    }
    
    @IBAction func quitGameAction(_ segue: UIStoryboardSegue) {
        soundController.playEffect(effect: .back)
        popView?.dismiss(animated: true, completion: {
            self.showPopOverView("quitView", 300, 220)
        })
    }
    
    //quit the game
    @IBAction func yesAction(_ segue: UIStoryboardSegue) {
        soundController.playEffect(effect: .back)
        if isOnlineGame { sendDeleteRequest("abandon") }
        self.popView?.removeFromParentViewController()
        self.performSegue(withIdentifier: "goToHome", sender: self)
    }
    
    @IBAction func backToGame(_ segue: UIStoryboardSegue) {
        combatView.isHidden = true
        self.updateGameBoard()
    }
    
    @IBAction func noAction(_ segue: UIStoryboardSegue) {
        soundController.playEffect(effect: .back)
        popView?.dismiss(animated: true, completion: {
            self.showPopOverView("optionView", 300, 220)
        })
    }
    
    @IBAction func musicViewAction(_ segue: UIStoryboardSegue) {
        soundController.playEffect(effect: .back)
        popView?.dismiss(animated: true, completion: {
            self.showPopOverView("musicView", 300, 220)
        })
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return game.board.matrix.grid.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let genericCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        guard let cell = genericCell as? CollectionViewCell else { return genericCell }
        
        cell.coordinate = convertIntoCoordinate(indexPath: indexPath)
        cell.checked = false
        cell.labelFrozenTurnLeft.text = ""
        
        if let piece = game.board.getPiece(at: cell.coordinate) {
            cell.imagePiece.image = UIImage(named: piece.icon)
            cell.imageSide.image = (piece.color == .white) ? UIImage(named: "label-rebel-symbol") : UIImage(named: "label-empire-symbol")
            cell.labelFrozenTurnLeft.text = (piece.frozenTurnsLeft > 0) ? String(piece.frozenTurnsLeft) : ""
            
            if game.board.isSpecialCell(cellCoordinate: cell.coordinate) {
                cell.imageSpecialCell.image = piece.color == .white ? UIImage(named: "label-rebel-symbol-gold") : UIImage(named: "label-empire-symbol-gold")
            }
            
        } else {
            if game.board.isSpecialCell(cellCoordinate: cell.coordinate) {
                cell.imageSpecialCell.image = UIImage(named: "specialCell")
            }
        }
        return cell
    }
}

extension ViewController {
    
    /// Convert into a type Coordinate an IndexPath
    func convertIntoCoordinate(indexPath: IndexPath) -> Coordinate {
        let row = indexPath.row/6
        let column = indexPath.row%6
        
        return Coordinate(row, column)
    }
    
    
    /// get collectionview cell
    ///
    /// - Parameter coordinate: matrix coordinate
    /// - Returns: cell
    func getCell(coordinate: Coordinate) -> CollectionViewCell? {
        
        if let cells = collectionView.visibleCells as? [CollectionViewCell] {
            guard let cell = cells.filter({$0.coordinate == coordinate}).first else { return nil }
            return cell
        }
        return nil
    }
    
    /// highlight allowed moves and attacks cells for selected cell
    ///
    /// - Parameters:
    ///   - cell: selected cell
    ///   - piece: piece
    func performFirstClickAction(_ cell: CollectionViewCell,_ piece: Piece) { //when user tap first time
        soundController.playEffect(effect: .back)
        startingCoordinate = cell.coordinate
        startingCell = cell
        deselectHightlightedPieces()
        // Highlight the possible actions
        highlightCells(cells: game.board.allowedMoves(coordinate: startingCoordinate!), action: .move)
        highlightCells(cells: game.board.allowedAttacks(coordinate: startingCoordinate!), action: .attack)
        //show piece information label
        showPieceInfoView(piece)
    }
    
    /// Update the information about the turn: visualize the number of special cells occupied and the number of enemies killed.
    func updateTurnInformationView() {
        
        // Set of turn image
        pieceMiniatureImage.image = (game.turn == .white) ? UIImage(named: "rebelsymbol") : UIImage(named: "empiresymbol")
        // Set of turn label
        if isHumanVsComputer && game.turn == AIPlayer.AIColor {
            pieceNameLabel.text = "\((game.turn == .white) ? whitePlayer : blackPlayer) is thinking."
        } else if isOnlineGame && game.turn == onlinePlayerColor {
            pieceNameLabel.text = "Turn of the online player."
        } else {
            pieceNameLabel.text = (game.turn == .white) ? "\(whitePlayer), it's your turn!" : "\(blackPlayer), it's your turn!"
        }
        // Set of number of special cells occupied
        infoTotalLabels.text = "Temples"
        pieceTotalLifeLabel.text = "\(game.piecesOnSpecialCell(color: game.turn))/3"
        pieceTotalLifeLabel.textColor = UIColor( red: CGFloat(68/255.0), green: CGFloat(189/255.0), blue: CGFloat(220/255.0), alpha: CGFloat(1.0))
        // Set of number of enemies killed
        infoAttackLabel.text = "Killed enemies"
        let deadPieces = game.pieces.filter { $0.currentVitality <= 0 && $0.color == game.turn }
        let pieces = game.pieces.filter { $0.color == game.turn }
        pieceAttackStLabel.text = "\(deadPieces.count)/\(pieces.count) "
        
        // Hide all others labels
        pieceMiniatureImage.isHidden = false
        pieceNameLabel.isHidden = false
        infoTotalLabels.isHidden = false
        pieceTotalLifeLabel.isHidden = false
        infoAttackLabel.isHidden = false
        pieceAttackStLabel.isHidden = false
        pieceDetailBackground.isHidden = false
    }
    
    
    /// Show piece information labels on click event
    ///
    /// - Parameter piece: selected piece
    func showPieceInfoView(_ piece: Piece){
        
        pieceMiniatureImage.image = UIImage(named: piece.miniature_icon)
        pieceNameLabel.text = "\(piece.frontend_name)"
        
        infoTotalLabels.text = "Current life"
        pieceTotalLifeLabel.text = String(piece.currentVitality) + "/" + String(piece.initialVitality)
        pieceTotalLifeLabel.textColor = (piece.currentVitality > piece.initialVitality/2) ? UIColor.green : UIColor.yellow
        
        infoAttackLabel.text = "Attack strength"
        pieceAttackStLabel.text = piece.frozenTurnsLeft > 0 ? "0" : String(piece.attack.attackStrength)
        
        infoMalusLabel.text = "Current malus"
        pieceTurnMalusLabel.text = piece.frozenTurnsLeft > 0 ? "Shocked" : "None"
        
        infoAttackDirectionLabel.text = "Attack direction"
        firstAttackDirection.image = (piece.attack.direction != nil) ? ((piece.attack.direction == .straight) ? UIImage(named: "horizontal-movement") : UIImage(named: "diagonal-movement")) : UIImage(named: "cannot-move")
        secondAttackDirection.image = (piece.attack.direction != nil) ? ((piece.attack.direction == .straight) ? UIImage(named: "vertical-movement") : UIImage()) : UIImage()
        
        showPieceInfoLabel(false)
    }
    
    /// hide or show piece info labels
    ///
    /// - Parameter isHidden: if true information label are hidden
    func showPieceInfoLabel(_ isHidden: Bool) {
        infoMalusLabel.isHidden = isHidden
        pieceTurnMalusLabel.isHidden = isHidden
        
        infoAttackDirectionLabel.isHidden = isHidden
        firstAttackDirection.isHidden = isHidden
        secondAttackDirection.isHidden = isHidden
    }
    
    /// do move or attack action
    ///
    /// - Parameter action: action type Move o Attack
    func doMoveAttackAction(_ action: Action) -> Bool {
        var isDone: Bool = false
        combatTurn = 0
        
        playerCombatPiece = game.board.getPiece(at: startingCoordinate!)
        opponentCombatPiece = game.board.getPiece(at: endingCell!.coordinate)
        
        (isDone,combatTurn) = game.play(startingCoordinate: startingCoordinate, endingCoordinate: endingCell!.coordinate, action: action, piece: nil)
        if isDone {
            if isFirstTurn { isFirstTurn = false }
            deselectHightlightedPieces()
            if isOnlineGame { timer.invalidate() }
            switch action {
            case .move:
                animateMovement()
            case .attack:
                animateAttack()
            default:
                break
            }
        } else {
            print("Error: Invalid Move")
        }
        return isDone
    }
    
    /// do spell action
    ///
    /// - Parameter action: action type spell
    func doSpellAction(_ action: Action,_ piece: Piece?) -> Bool {
        var isDone: Bool = false
        playerCombatPiece = nil
        opponentCombatPiece = nil
        
        switch action {
        case .spell(.revive):
            playerCombatPiece = piece
            opponentCombatPiece = game.board.getPiece(at: startingCoordinate!)
        case .spell(.teleport):
            if let startingCoordinate = startingCoordinate, let endingCell = endingCell {
                playerCombatPiece = game.board.getPiece(at: startingCoordinate)
                opponentCombatPiece = game.board.getPiece(at: endingCell.coordinate)
            }
        default:
            break
        }
        
        (isDone,combatTurn) = game.play(startingCoordinate: startingCoordinate, endingCoordinate: endingCell?.coordinate, action: action, piece: piece)
        deselectHightlightedPieces()
        if isDone {
            if isFirstTurn { isFirstTurn = false }
            if isOnlineGame { timer.invalidate() }
            switch action {
            case .spell(.teleport):
                animateTeleport()
            case .spell(.freeze):
                animateSpell(spell: .freeze)
            case .spell(.heal):
                animateSpell(spell: .heal)
            case .spell(.revive):
                animateSpell(spell: .revive)
            default:
                showLabelCombat()
            }
        } else {
            deselectTap()
            deselectSpellLabels()
            print("Error: Invalid Move")
        }
        return isDone
    }
    
    func secondTapAction(cell: CollectionViewCell) {
        soundController.playEffect(effect: .back)
        var action: Action?
        
        if cell.movingCell, !cell.attackingCell { action = .move; userMove = "\(userMove)M"}
        if cell.attackingCell, !cell.movingCell { action = .attack; userMove =  "\(userMove)A" }
        
        if let action = action { let _ = doMoveAttackAction(action) }
        
        if cell.attackingCell, cell.movingCell {
            
            // get a reference to the view controller for the popover
            let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popover")
            
            // set the presentation style
            popController.modalPresentationStyle = UIModalPresentationStyle.popover
            
            // set up the popover presentation controller
            popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
            popController.popoverPresentationController?.delegate = self
            popController.popoverPresentationController?.sourceView = cell  // button
            popController.popoverPresentationController?.sourceRect = cell.bounds
            popController.preferredContentSize = CGSize(width: 175, height: 85)
            popController.popoverPresentationController?.backgroundColor =  UIColor( red: CGFloat(11/255.0), green: CGFloat(30/255.0), blue: CGFloat(37/255.0), alpha: CGFloat(1.0) )
            
            // present the popover
            self.present(popController, animated: true, completion: nil)
        }
    }
    
    /// Movement animation: move a selected piece from its origin point to the tapped location
    func animateMovement() {
        soundController.playEffect(effect: .slidingMovement)
        self.moveImage.image = self.startingCell?.imagePiece.image
        
        self.moveImage.frame.origin = CGPoint(x: (self.startingCell?.frame.origin.x)! + self.collectionView.frame.origin.x, y: (self.startingCell?.frame.origin.y)! + self.collectionView.frame.origin.y)
        
        self.moveImage.isHidden = false
        
        UIView.animate(withDuration: 2, animations: {
            
            var newOrigin: CGPoint = CGPoint(x: 0.0, y: 0.0)
            newOrigin.x = (self.endingCell?.frame.origin.x)! + self.collectionView.frame.origin.x
            newOrigin.y = (self.endingCell?.frame.origin.y)! + self.collectionView.frame.origin.y
            
            self.moveImage.frame.origin = CGPoint(x: newOrigin.x, y: newOrigin.y)
            self.startingCell?.imagePiece.isHidden = true
            
        }, completion: { finished in
            self.moveImage.isHidden = true
            self.showLabelCombat()
        })
    }
    
    func animateAttack() {
        
        var startingOrigin = CGPoint()
        startingOrigin.x = (self.startingCell?.frame.origin.x)! + self.collectionView.frame.origin.x
        startingOrigin.y = (self.startingCell?.frame.origin.y)! + self.collectionView.frame.origin.y
        
        self.moveImage.image = self.startingCell?.imagePiece.image
        self.moveImage.frame.origin = startingOrigin
        self.moveImage.isHidden = false
        
        UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseIn], animations: {
            self.startingCell?.imagePiece.isHidden = true
            
            var newOrigin: CGPoint = CGPoint()
            newOrigin.x = (self.endingCell?.frame.origin.x)! + self.collectionView.frame.origin.x
            newOrigin.y = (self.endingCell?.frame.origin.y)! + self.collectionView.frame.origin.y
            
            self.moveImage.frame.origin = CGPoint(x: newOrigin.x, y: newOrigin.y)
            
        }, completion: { finished in
            UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseOut], animations: {
                
                self.moveImage.frame.origin = startingOrigin
                
            }, completion: { finished in
                self.moveImage.isHidden = true
                self.updateGameBoard()
            })
        })
        
        // Play Sound
        if let playerPiece = self.game.board.getPiece(at: self.startingCoordinate!) {
            switch playerPiece.name {
            case "Dragon":
                self.soundController.playEffect(effect: .dragonBlaster)
            case "Archer":
                self.soundController.playEffect(effect: .blasterSniper)
            case "Giant":
                self.soundController.playEffect(effect: .giantCannon)
            case "Knight":
                self.soundController.playEffect(effect: .lightsaber)
            default:
                break
            }
        }
    }
    
    /// Shows the label "Combat!" before calling the method that shows up the combat view
    func showLabelCombat() {
        if combatTurn > 0 {
            combatLabel.isHidden = false
            _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.animateCombat), userInfo: nil, repeats: false)
        } else {
            self.updateGameBoard()
        }
    }
    
    /// Open the window of Combat and set its attributes (players, pieces, number of turns)
    func openWindowCombat() {
        combatViewController?.setAttributes(game.whitePlayer.name, game.blackPlayer.name, playerCombatPiece!, opponentCombatPiece!, combatTurn)
        combatViewController?.updateView()
    }
    
    /// Set of the duration of the combat. After that amount of time the window is automatically closed.
    func animateCombat() {
        
        combatLabel.isHidden = true
        
        if let _ = playerCombatPiece, let _ = opponentCombatPiece {
            combatView.isHidden = false
            self.openWindowCombat()
            
            // length of 1 round: 5.0 s of animation
            // length of dead animation 1.2 s of animation
            // the deadline of the combat view is set as #round * 5.0 s + 1.2 s
            let delay = Double(combatTurn * 5) + 1.2
            DispatchQueue.main.asyncAfter(deadline: (.now() + delay)) {
                if !self.combatView.isHidden {
                    self.combatView.isHidden = true
                    self.updateGameBoard()
                }
            }
        }
    }
    
    /// Animation of the spell: if spell is a freeze, heal or revive spell this method create an animation of the background of the cell selected as destination.
    func animateSpell(spell: Spell) {
        switch spell {
        case .freeze:
            soundController.playEffect(effect: .shock)
        case .heal:
            soundController.playEffect(effect: .heal)
        case .revive:
            soundController.playEffect(effect: .revive)
        default:
            break
        }
        
        startingCell = getCell(coordinate: startingCoordinate!)
        startingCell?.imageBackground.animationImages = spell == .freeze ? [UIImage(named: "selectedCell")!, UIImage(named: "frozenCell")!] : [UIImage(named: "selectedCell")!, UIImage(named: "healingCell")!]
        startingCell?.imageBackground.animationDuration = 0.30
        
        UIView.animate(withDuration: 2.5, animations: {
            self.startingCell?.imageBackground.startAnimating()
            self.startingCell?.imageBackground.alpha = 0
        }, completion: { (success) in
            self.startingCell?.imageBackground.alpha = 1
            self.startingCell?.imageBackground.stopAnimating()
            
            self.showLabelCombat()
        })
        
        
    }
    
    /// Teleport spell animation. The piece that as to be teleported is animated with blur effect. Once it has become transparent it is shown in the destination cell selected by the user with the same effect.
    func animateTeleport() {
        soundController.playEffect(effect: .teleport)
        startingCell = getCell(coordinate: startingCoordinate!)
        startingCell?.imageBackground.animationImages = [UIImage(named: "selectedCell")!, UIImage(named: "greenCell")!]
        startingCell?.imageBackground.animationDuration = 0.30
        
        self.moveImage.image = self.startingCell?.imagePiece.image
        self.moveImage.alpha = 0
        self.moveImage.isHidden = false
        
        self.moveImage.frame.origin = CGPoint(x: (self.endingCell?.frame.origin.x)! + self.collectionView.frame.origin.x, y: (self.endingCell?.frame.origin.y)! + self.collectionView.frame.origin.y)
        
        startingCell?.imageBackground.startAnimating()
        UIView.animate(withDuration: 1.5, animations: {
            
            self.startingCell?.imagePiece.alpha = 0
            
        }, completion: { finished in
            self.startingCell?.imageBackground.stopAnimating()
            self.startingCell?.imagePiece.isHidden = true
            self.startingCell?.imagePiece.alpha = 1
            
            if self.combatTurn > 0 {
                self.endingCell?.imageBackground.animationImages = [UIImage(named: "selectedCell")!,UIImage(named: "orangeCell")!]
            }else {
                self.endingCell?.imageBackground.animationImages = [UIImage(named: "selectedCell")!,UIImage(named: "greenCell")!]
            }
            self.endingCell?.imageBackground.animationDuration = 0.30
            self.endingCell?.imageBackground.startAnimating()
            UIView.animate(withDuration: 1.5, animations: {
                self.moveImage.alpha = 1
            }, completion: { (finished) in
                self.endingCell?.imageBackground.stopAnimating()
                self.moveImage.isHidden = true
                self.showLabelCombat()
            })
        })
    }
    
    /// Method that monitorized the status of the game.
    func isGameOver() {
        
        // Save match statistics and show the winner view
        if game.isGameEnded {
            timer.invalidate()
            timerLabel.isHidden = true
            // White Winner
            if game.winner == .white {
                CoreDataController.shared.updatePlayer(whitePlayer, 1, 0, 1, 0)
                CoreDataController.shared.updatePlayer(blackPlayer, 0, 1, 0, 1)
                CoreDataController.shared.addNewMatch(whitePlayer, blackPlayer, whitePlayer, game.turnsCount)
                // Single player || online game
                if (isHumanVsComputer && game.winner == AIPlayer.AIColor)  || (isOnlineGame && game.winner == onlinePlayerColor) {
                    winnerViewController?.setWinnerAttributes("banner-defeat-lato-oscuro", blackPlayer, .black, false)
                } else {    // Multiplayer || local player won
                    winnerViewController?.setWinnerAttributes("banner-winner-lato-chiaro", whitePlayer, .white, true)
                }
            }
            // Black Winner
            else if game.winner == .black {
                CoreDataController.shared.updatePlayer(blackPlayer, 0, 1, 1, 0)
                CoreDataController.shared.updatePlayer(whitePlayer, 1, 0, 0, 1)
                CoreDataController.shared.addNewMatch(whitePlayer, blackPlayer, blackPlayer, game.turnsCount)
                // Single player || online game
                if (isHumanVsComputer && game.winner == AIPlayer.AIColor)  || (isOnlineGame && game.winner == onlinePlayerColor) {
                    winnerViewController?.setWinnerAttributes("banner-defeat-lato-chiaro", whitePlayer, .white, false)
                } else {    // Multiplayer || local player won
                    winnerViewController?.setWinnerAttributes("banner-winner-lato-oscuro", blackPlayer, .black, true)
                }
            }
            // Draw
            else {
                CoreDataController.shared.updatePlayer(whitePlayer, 1, 0, 0, 0)
                CoreDataController.shared.updatePlayer(blackPlayer, 0, 1, 0, 0)
                CoreDataController.shared.addNewMatch(whitePlayer, blackPlayer, "Draw", game.turnsCount)
                winnerViewController?.setWinnerAttributes("banner-winner-draw", "",nil,nil)
            }
            winnerView.isHidden = false
        }
        
    }
    
    /// Method that update all the labels and images on the board.
    func updateGameBoard() {
        //send usermove to onlineplayer if game is not terminated and it is onlineplayer turn OR game is terminated and it is my turn (FINAL MOVE)
        if isOnlineGame, !isFirstTurn, (!game.isGameEnded && game.turn == onlinePlayerColor)  || (game.isGameEnded && game.turn != onlinePlayerColor) {
            timer.invalidate()
            timerLabel.isHidden = true
            completeUserMoveString() // send user move to server
        }
        
        isGameOver()
        
        // Update pieces
        if let cells = collectionView.visibleCells as? [CollectionViewCell] {
            for cell in cells {
                if let piece = game.board.getPiece(at: cell.coordinate) {
                    
                    cell.imageSide.image = (piece.color == .white) ? (game.board.isSpecialCell(cellCoordinate: cell.coordinate) ? UIImage() : UIImage(named: "label-rebel-symbol")) : (game.board.isSpecialCell(cellCoordinate: cell.coordinate) ? UIImage() : UIImage(named: "label-empire-symbol"))
                    
                    
                    cell.labelFrozenTurnLeft.text = (piece.isFrozen) ? String(piece.frozenTurnsLeft) : ""
                    
                    if game.board.isSpecialCell(cellCoordinate: cell.coordinate) {
                        cell.imageSpecialCell.image = (piece.color == .white) ? UIImage(named: "label-rebel-symbol-gold") : UIImage(named: "label-empire-symbol-gold")
                    }
                    cell.imagePiece.image = (piece.isFrozen == true) ? UIImage(named: piece.icon+"-frozen") : UIImage(named: piece.icon)
                    
                    cell.imagePiece.isHidden = false
                    
                    
                } else {
                    cell.imagePiece.image = UIImage()
                    cell.imageSide.image = UIImage()
                    cell.labelFrozenTurnLeft.text = ""
                    
                    if game.board.isSpecialCell(cellCoordinate: cell.coordinate) {
                        cell.imageSpecialCell.image = UIImage(named: "specialCell")
                    }
                    
                }
            }
        }
        
        // Update spells
        updateSpellLabels()
        //update dead pieces
        updateDeadpieces()
        // Reset the variables
        deselectTap()
        updateTurnInformationView()
        
        // If H vs C Game and it's the Computer turn, trigger the Artificial Intelligence
        if isHumanVsComputer, game.turn == AIPlayer.AIColor, !isFirstTurn, !game.isGameEnded {
            prepareAIMove()
            makeAIMove()
        }
        
        if isOnlineGame, game.turn != onlinePlayerColor, !game.isGameEnded {
            timer.invalidate()
            counter = 30
            timerLabel.isHidden = false
            timerLabel.text = ""
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        }
    }
    
    // called every time interval from the timer
    func timerAction() {
        counter -= 1
        guard counter >= 0 else {
            print("time over")
            errorAlert("Time over, Game is terminated")
            sendDeleteRequest("abandon")
            return
        }
        
        if counter < 10 {
            timerLabel.text = "00:0\(counter)"
        }else{
            timerLabel.text = "00:\(counter)"
        }
    }
    
    /// Deselect the label of the selected spell
    func deselectSpellLabels() {
        selectedSpellHeal.isHidden = true
        selectedSpellShock.isHidden = true
        selectedSpellRevive.isHidden = true
        selectedSpellTeleport.isHidden = true
    }
    
    /// Update the images of the spell. If in a turn the spell has been used, its image turn into the "used" one.
    func updateSpellLabels() {
        
        deselectSpellLabels()
        
        var spells: [Spell: Bool]?
        var mageImage: String = ""
        var mageAlive: Bool = true
        let turn: Color = game.turn
        
        spells = game.turn == .white ? game.spellWhite : game.spellBlack
        mageImage = game.turn == .white ? "Yoda-miniatura-Mage" : "Palpatine-miniatura-Mage"
        mageAlive = game.turn == .white ? game.isMageAlive(color: .white) : game.isMageAlive(color: .black)
        
        if let spells = spells {
            setbtnSpellAttribute(btnSpellMage, mageImage, mageAlive, turn, nil)
            setbtnSpellAttribute(btnSpellHeal, "heal", (spells[.heal]!) ? (mageAlive ? true : false) : false, turn, labelHeal)
            setbtnSpellAttribute(btnSpellFreeze, "freeze", (spells[.freeze]!) ? (mageAlive ? true : false) : false, turn, labelShock)
            setbtnSpellAttribute(btnSpellTeleport, "teleport", (spells[.teleport]!) ? (mageAlive ? true : false) : false, turn, labelTeleport)
            setbtnSpellAttribute(btnSpellRevive, "revive", (spells[.revive]!) ? (mageAlive ? true : false) : false, turn, labelRevive)
        }
    }
    
    func setbtnSpellAttribute(_ btnSpell: UIButton,_ imageName: String, _ isEnabled: Bool,_ turn: Color,_ label: UILabel?) {
        
        btnSpell.isEnabled = isEnabled
        let image = (isEnabled) ? ((turn == .white) ? imageName+"W" : imageName+"B") : imageName + "-used"
        btnSpell.setImage(UIImage(named: image)?.withRenderingMode(.alwaysOriginal), for: .normal)
        
        label?.textColor = (isEnabled) ? UIColor( red: CGFloat(55/255.0), green: CGFloat(181/255.0), blue: CGFloat(201/255.0), alpha: CGFloat(1.0) ) : UIColor.gray
    }
    
    func updateSelectedPiece(tapped: Bool, at selectedPiece: Coordinate?) {
        if let selectedPiece = selectedPiece {
            getCell(coordinate: selectedPiece)?.checked = tapped
            if tapped == true { getCell(coordinate: selectedPiece)?.imageBackground.image = UIImage(named: "selectedCell") }
            else { getCell(coordinate: selectedPiece)?.imageBackground.image = UIImage() }
        }
    }
    
    // Highlight cells passed as parameter
    func highlightCells(cells: [Coordinate], action: Action) {
        
        if let visibleCells = collectionView.visibleCells as? [CollectionViewCell] {
            for visibleCell in visibleCells {
                if cells.contains(visibleCell.coordinate){
                    visibleCell.setBackgroundCell(action: action)
                }
            }
        }
    }
    
    func deselectTap() {
        userMove = ""
        startingCoordinate = nil
        startingCell = nil
        endingCell = nil
        spellSelected = nil
        showPieceInfoLabel(true)
        updateTurnInformationView()
    }
    
    // deseleziona i pezzi colorati
    func deselectHightlightedPieces() {
        
        if let cells = collectionView.visibleCells as? [CollectionViewCell] {
            for cell in cells {
                if cell.movingCell { cell.setBackgroundCell(action: .move) }
                if cell.attackingCell { cell.setBackgroundCell(action: .attack) }
                if cell.healingCell { cell.setBackgroundCell(action: .spell(.heal)) }
                if cell.freezingCell { cell.setBackgroundCell(action: .spell(.freeze)) }
                if cell.teleportingCell { cell.setBackgroundCell(action: .spell(.teleport)) }
                if cell.revivingCell {
                    cell.setBackgroundCell(action: .spell(.revive))
                    if let piece = game.board.getPiece(at: cell.coordinate) {
                        cell.imagePiece.image = UIImage(named: piece.icon)
                        cell.imagePiece.isHidden = false
                    }
                }
            }
        }
    }
    
    /// Update the pieces that are currently dead by setting its image
    func updateDeadpieces(){
        
        setDefaultDeadImages()
        let deadPieces = game.pieces.filter({!$0.isAlive && game.turn == $0.color})
        
        for deadPiece in deadPieces {
            
            let name = deadPiece.icon
            
            switch name {
            case "LS-Yoda-mage", "DS-Palpatine-mage":
                firstDead.image = UIImage(named: name+"-revive")
                break
            case "LS-Luke-knight", "DS-Darth-vader-knight":
                secondDead.image = UIImage(named: name+"-revive")
                break
            case "LS-BenKenobi-knight", "DS-Kylo-knight":
                thirdDead.image = UIImage(named: name+"-revive")
                break
            case "LS-pilot-squire", "DS-General-veers-squire":
                fourthDead.image = UIImage(named: name+"-revive")
                break
            case "LS-pilot-squire-1", "DS-General-veers-squire-1":
                fifthDead.image = UIImage(named: name+"-revive")
                break
            case "LS-Chewbecca-archer", "DS-Boba-fett-archer":
                sixthDead.image = UIImage(named: name+"-revive")
                break
            case "LS-Millennium-falcon-dragon", "DS-Tie-dragon":
                seventhDead.image = UIImage(named: name+"-revive")
                break
            case "LS-AAT-giant", "DS-Atat-giant":
                eightDead.image = UIImage(named: name+"-revive")
                break
            default:
                break
            }
        }
    }
    
    /// Set of the dead images by default
    func setDefaultDeadImages(){
        // setting default images
        firstDead.image = (game.turn == .white) ? UIImage(named: "LS-Yoda-mage-dead") : UIImage(named: "DS-Palpatine-mage-dead")
        secondDead.image = (game.turn == .white) ? UIImage(named: "LS-Luke-knight-dead") : UIImage(named: "DS-Darth-vader-knight-dead")
        thirdDead.image = (game.turn == .white) ? UIImage(named: "LS-BenKenobi-knight-dead") : UIImage(named: "DS-Kylo-knight-dead")
        fourthDead.image = (game.turn == .white) ? UIImage(named: "LS-pilot-squire-dead") : UIImage(named: "DS-General-veers-squire-dead")
        fifthDead.image = (game.turn == .white) ? UIImage(named: "LS-pilot-squire-1-dead") : UIImage(named: "DS-General-veers-squire-1-dead")
        sixthDead.image = (game.turn == .white) ? UIImage(named: "LS-Chewbecca-archer-dead") : UIImage(named: "DS-Boba-fett-archer-dead")
        seventhDead.image = (game.turn == .white) ? UIImage(named: "LS-Millennium-falcon-dragon-dead") : UIImage(named: "DS-Tie-dragon-dead")
        eightDead.image = (game.turn == .white) ? UIImage(named: "LS-AAT-giant-dead") : UIImage(named: "DS-Atat-giant-dead")
    }
    
    func reviveDeadPiece(){
        let deadPieces = game.pieces.filter({!$0.isAlive && game.turn == $0.color})
        if deadPieces.count > 0 {
            for piece in deadPieces {
                let result = game.getRevivePieceCoordinate(piece)
                if let coordinate = result.0 {
                    let cell = getCell(coordinate: coordinate)
                    cell?.setBackgroundCell(action: .spell(.revive))
                    pieceToRevive[piece.initialPosition] = coordinate
                    cell?.imagePiece.image = UIImage(named: "\(piece.icon)-revive")
                    cell?.imagePiece.isHidden = false
                    if result.1 { //combat
                        cell?.setBackgroundCell(action: .move)
                        cell?.setBackgroundCell(action: .attack)
                    }
                }
            }
        } else { errorLabelAnimation() }
        
    }
    
}


extension ViewController: UICollectionViewDelegateFlowLayout {
    //1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let availableWidth = collectionView.frame.width
        let widthPerItem = availableWidth / 6
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
}
