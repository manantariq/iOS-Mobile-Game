//
//  AudioViewController.swift
//  MobileApp16
//
//  Created by Alessandro Castiglioni on 12/01/17.
//
//

import UIKit

class AudioVideoController: UIViewController {
    
    let soundController = SoundController.sharedInstance
    
    @IBOutlet weak var fxSwitch: UISwitch!
    @IBOutlet weak var musicSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let settings = CoreDataController.shared.getAppSettings() {
            fxSwitch.isOn = settings.sounds
            musicSwitch.isOn = settings.music
        }
    }
    
    @IBAction func soundSwitchChanged(_ sender: UISwitch) {
        if sender == fxSwitch {
            soundController.toggleFX(active: fxSwitch.isOn)
        }
        if sender == musicSwitch {
            soundController.toggleBackgroundMusic(active: musicSwitch.isOn)
        }
    }
    
}
