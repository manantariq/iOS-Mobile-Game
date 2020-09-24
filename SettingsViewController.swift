//
//  SettingsViewController.swift
//  MobileApp16
//
//  Created by Manan Tariq on 11/01/17.
//
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    let soundController = SoundController.sharedInstance

    // hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var fxSwitch: UISwitch!
    @IBOutlet weak var musicSwitch: UISwitch!
    @IBOutlet weak var serverTextField: UITextField!
    @IBOutlet weak var saveServerRoom: UIButton!
    @IBOutlet weak var currentServerRoom: UILabel!
    @IBOutlet weak var tutorialSwitch: UISwitch!
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGesture))
        swipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipe)
        
        serverTextField.isHidden = true
        saveServerRoom.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.serverTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Updating Settings
        if let settings = CoreDataController.shared.getAppSettings() {
            fxSwitch.isOn = settings.sounds
            musicSwitch.isOn = settings.music
            currentServerRoom.text = settings.serverRoom
            tutorialSwitch.isOn = settings.tutorial
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }
    /// tap action
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true); //hide keyboard
    }
    
    @IBAction func soundSwitchChanged(_ sender: UISwitch) {
        if sender == fxSwitch {
            soundController.toggleFX(active: fxSwitch.isOn)
        }
        if sender == musicSwitch {
            soundController.toggleBackgroundMusic(active: musicSwitch.isOn)
        }
    }
    
    func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.right :
            performSegue(withIdentifier: "settingsTohome", sender: self)
            break
        default:
            break
        }
    }
    
    @IBAction func btnHomePressed(_ sender: UIButton) {
        soundController.playEffect(effect: .select)
    }
    ///change server room
    @IBAction func saveServerRoomAction(_ sender: UIButton) {
        
        if !serverTextField.text!.isEmpty,
            let text = serverTextField.text {
            currentServerRoom.text = text
            CoreDataController.shared.updateAppSettings(nil, nil, text,nil)
        }
        serverTextField.isHidden = true
        saveServerRoom.isHidden = true
    }
    
    @IBAction func showRoomField(_ sender: Any) {
        serverTextField.isHidden = false
        saveServerRoom.isHidden = false
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    
    /// hide textfield keyboard when press done
    ///
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func swtichTutorialAction(_ sender: UISwitch) {
        CoreDataController.shared.updateAppSettings(nil, nil, nil, sender.isOn)
    }
}
