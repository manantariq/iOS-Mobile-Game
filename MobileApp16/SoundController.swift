//
//  SoundController.swift
//  MobileApp16
//
//  Created by Alberto Federico Pagani on 11/01/17.
//
//

import Foundation
import AVFoundation

enum SoundEffects {
    case select, back, changeFaction, slidingMovement
    case blasterShot, blasterSniper, dragonBlaster, lightsaber, giantCannon, mageWhite, mageBlack
    case shock, teleport, heal, revive
}

enum EndGameMusic {
    case victoryRebel, defeatRebel, victoryEmpire, defeatEmpire, draw
}

class SoundController {
    
    //Singleton declaration
    static let sharedInstance: SoundController = SoundController()
    
    // Data Controller Instance
    let dataController = CoreDataController.shared
    
    // Settings
    var fxEnabled: Bool = true
    var musicEnabled: Bool = true
    
    //View sounds
    var backgroundMusic: AVAudioPlayer
    var select: AVAudioPlayer
    var back: AVAudioPlayer
    var slidingMovement: AVAudioPlayer
    var changeFaction: AVAudioPlayer
    
    //Attack and combat sounds
    var blasterShot: AVAudioPlayer
    var blasterSniper: AVAudioPlayer
    var dragonBlaster: AVAudioPlayer
    var lightsaber: AVAudioPlayer
    var giantCannon: AVAudioPlayer
    var mageWhite: AVAudioPlayer
    var mageBlack: AVAudioPlayer
    
    //Spell sounds
    var shock: AVAudioPlayer
    var teleport: AVAudioPlayer
    var heal: AVAudioPlayer
    var revive: AVAudioPlayer
    
    //End game sounds
    var victoryRebel: AVAudioPlayer
    var defeatRebel: AVAudioPlayer
    var victoryEmpire: AVAudioPlayer
    var defeatEmpire: AVAudioPlayer
    var draw: AVAudioPlayer

    //Sounds initialization
    private init() {
        
        if let settings = dataController.getAppSettings() {
            fxEnabled = settings.sounds
            musicEnabled = settings.music
        }
        
        backgroundMusic = SoundController.setupAudioPlayerWithFile(file: "StarWarsThemeAAC", type: "aac")
        
        select = SoundController.setupAudioPlayerWithFile(file: "select", type: "aiff")
        select.volume = 0.7
        
        back = SoundController.setupAudioPlayerWithFile(file: "back", type: "aiff")
        
        slidingMovement = SoundController.setupAudioPlayerWithFile(file: "slidingMovement", type: "wav")
        
        changeFaction = SoundController.setupAudioPlayerWithFile(file: "changeFaction", type: "aiff")
        
        blasterShot = SoundController.setupAudioPlayerWithFile(file: "blasterShot", type: "aiff")
        
        blasterSniper = SoundController.setupAudioPlayerWithFile(file: "blasterSniper", type: "aiff")
        
        dragonBlaster = SoundController.setupAudioPlayerWithFile(file: "dragonBlaster", type: "aiff")
        
        lightsaber = SoundController.setupAudioPlayerWithFile(file: "lightsaber", type: "wav")
        lightsaber.volume = 0.3
        
        giantCannon = SoundController.setupAudioPlayerWithFile(file: "giantCannon", type: "aiff")
        giantCannon.volume = 0.4
        
        mageWhite = SoundController.setupAudioPlayerWithFile(file: "mageWhite", type: "wav")
        mageWhite.volume = 0.2
        
        mageBlack = SoundController.setupAudioPlayerWithFile(file: "mageBlack", type: "wav")
        mageBlack.volume = 0.3
        
        shock = SoundController.setupAudioPlayerWithFile(file: "shock", type: "wav")
        shock.volume = 0.3
        
        teleport = SoundController.setupAudioPlayerWithFile(file: "teleport", type: "wav")
        teleport.volume = 0.4
        
        heal = SoundController.setupAudioPlayerWithFile(file: "heal", type: "wav")
        heal.volume = 0.2
        
        revive = SoundController.setupAudioPlayerWithFile(file: "revive", type: "wav")
        revive.volume = 0.4
        
        victoryRebel = SoundController.setupAudioPlayerWithFile(file: "victoryRebel", type: "aiff")
        
        defeatRebel = SoundController.setupAudioPlayerWithFile(file: "defeatRebel", type: "aiff")
        
        victoryEmpire = SoundController.setupAudioPlayerWithFile(file: "victoryEmpire", type: "aiff")
        
        defeatEmpire = SoundController.setupAudioPlayerWithFile(file: "defeatEmpire", type: "aiff")
        
        draw = SoundController.setupAudioPlayerWithFile(file: "draw", type: "wav")

        
    }
    //Set up function for AVAudioPlayer
    private static func setupAudioPlayerWithFile(file:String, type:String) -> AVAudioPlayer  {
        
        let path = Bundle.main.path(forResource: file, ofType:type)
        let url = NSURL.fileURL(withPath: path!)
        let audioPlayer = try! AVAudioPlayer(contentsOf: url)
        return audioPlayer
        
    }
    
    //Update sounds effects preferences on db
    func toggleFX(active: Bool) {
        // Storing the setting
        if fxEnabled != active {
            fxEnabled = active
            dataController.updateAppSettings(nil, active, nil,nil)
        }
    }
    
    //Update music preferences on db
    func toggleBackgroundMusic(active: Bool) {
        if musicEnabled != active {
            musicEnabled = active
            // Storing the setting
            dataController.updateAppSettings(active, nil, nil,nil)
            // Applying the setting
            if musicEnabled {
                playBackgroundMusic()
            } else {
                stopBackgroundMusic()
            }
        }
    }
    
    //Stop ending music
    func stopEndingMusic() {
        victoryRebel.stop()
        defeatRebel.stop()
        victoryEmpire.stop()
        defeatEmpire.stop()
        draw.stop()
        
        victoryRebel.currentTime = 0
        defeatRebel.currentTime = 0
        victoryEmpire.currentTime = 0
        defeatEmpire.currentTime = 0
        draw.currentTime = 0
    }
    
    //Start ending music checking fxEnabled before
    func playEndingMusic(endingMusic: EndGameMusic) {
        guard fxEnabled else { return }
        pauseBackgroundMusic()
        switch endingMusic {
        case .victoryRebel:
            victoryRebel.play()
        case .defeatRebel:
            defeatRebel.play()
        case .victoryEmpire:
            victoryEmpire.play()
        case .defeatEmpire:
            defeatEmpire.play()
        case .draw:
            draw.play()
        }
    }
    
    //Start effects checking fxEnabled before
    func playEffect(effect: SoundEffects) {
        guard fxEnabled else { return }
        switch effect {
        case .select:
            select.play()
        case .back:
            back.play()
        case .slidingMovement:
            slidingMovement.play()
        case .changeFaction:
            changeFaction.play()
        case .blasterShot:
            blasterShot.play()
        case .blasterSniper:
            blasterSniper.play()
        case .dragonBlaster:
            dragonBlaster.play()
        case .lightsaber:
            lightsaber.play()
        case .giantCannon:
            giantCannon.play()
        case .mageWhite:
            mageWhite.play()
        case .mageBlack:
            mageBlack.play()
        case .shock:
            shock.play()
        case .teleport:
            teleport.play()
        case .heal:
            heal.play()
        case .revive:
            revive.play()
        }
    }
    
    //Start background music checking musicEnabled before
    func playBackgroundMusic() {
        guard musicEnabled else { return }
        if !backgroundMusic.isPlaying {
            
            backgroundMusic.volume = 0.1
            backgroundMusic.numberOfLoops = -1
            
            backgroundMusic.play()
        }
    }
    
    //Stop background music and set starting point of the file to the starting one
    func stopBackgroundMusic() {
        if backgroundMusic.isPlaying {
            backgroundMusic.stop()
            backgroundMusic.currentTime = 0
        }
    }
    
    //Pause background music not resetting currentTime of the played file
    func pauseBackgroundMusic() {
        if backgroundMusic.isPlaying {
            backgroundMusic.stop()
        }
    }
    
}
