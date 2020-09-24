//
//  CollectionViewCell.swift
//  MobileApp16
//
//  Created by Ilaria Carlini on 28/11/16.
//
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageBackground: UIImageView!
    @IBOutlet weak var imagePiece: UIImageView!
    @IBOutlet weak var imageSide: UIImageView!
    @IBOutlet weak var labelFrozenTurnLeft: UILabel!
    @IBOutlet weak var imageSpecialCell: UIImageView!

    var coordinate = Coordinate(0,0)
    
    var checked = false {
        didSet {
            //backgroundColor = UIColor.white
        }
    }
    
    var movingCell = false
    var attackingCell = false
    var healingCell = false
    var freezingCell = false
    var teleportingCell = false
    var revivingCell = false
    
    
    /// Method call in the view controller to manage the cell background colors.
    func setBackgroundCell(action: Action) {
        switch action {
        case .move:
            if movingCell == true {
                movingCell = false
                imageBackground.image = UIImage()
            }
            else {
                movingCell = true
                imageBackground.image = UIImage(named: "greenCell.png")
            }
        case .attack:
            if attackingCell == true {
                attackingCell = false
                imageBackground.image = UIImage()
            }
            else {
                if movingCell == true {
                    attackingCell = true
                    imageBackground.image = UIImage(named: "orangeCell.png")
                } else {
                    attackingCell = true
                    imageBackground.image = UIImage(named: "redCell.png")
                }
        }
        case .spell(let spellDescription):
            switch spellDescription {
            case .heal:
                if healingCell == true { healingCell = false; imageBackground.image =  UIImage()}
                else { healingCell = true; imageBackground.image = UIImage(named: "healingCell") }
            case .freeze:
                if freezingCell == true { freezingCell = false; imageBackground.image =  UIImage()}
                else { freezingCell = true; imageBackground.image = UIImage(named: "healingCell")}
            case .teleport:
                if teleportingCell == true { teleportingCell = false; imageBackground.image =  UIImage()}
                else { teleportingCell = true; imageBackground.image = UIImage(named: "healingCell")}
            case .revive:
                if revivingCell == true { revivingCell = false; imageBackground.image =  UIImage(); imagePiece.isHidden = true}
                else { revivingCell = true; imageBackground.image = UIImage(named: "healingCell")}
            }
        }
    }
}
