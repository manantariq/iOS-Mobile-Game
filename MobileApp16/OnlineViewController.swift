//
//  OnlineViewController.swift
//  MobileApp16
//
//  Created by Manan Tariq on 31/12/16.
//
//

import UIKit

class OnlineViewController: UIViewController {

    // hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    var players: [PlayerStatistic]?
    var isWhiteSide: Bool = true //player choose white side
    let whiteSideImage = "rebelsymbol"
    let blackSideImage = "empiresymbol"
    let firstPlayerPickerView: UIPickerView = UIPickerView()
    var url: URL?
    let soundController = SoundController.sharedInstance
    
    var onlineId: String?
    var gameUrl: String?
    
    @IBOutlet weak var firstPlayer: UITextField!
    @IBOutlet weak var sideFirstPlayer: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var waitLabel: UILabel!
    @IBOutlet weak var btnPlay: UIButton!
    
    @IBOutlet weak var searchingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        players = CoreDataController.shared.getAllPlayers()
        
        let pickerViewBackgroundImage = UIImage(named: "backgroundGameBlur")
        if let bImage = pickerViewBackgroundImage {
            firstPlayerPickerView.backgroundColor = UIColor(patternImage: bImage)
        }
        firstPlayerPickerView.delegate = self
        
        //sideFirstPlayer.setImage(UIImage(named: whiteSideImage)?.withRenderingMode(.alwaysOriginal), for: .normal)
        
        errorLabel.isHidden = true
        waitLabel.isHidden = true
        sideFirstPlayer.isEnabled = false
        if let room = CoreDataController.shared.getAppSettings()?.serverRoom {
            url = URL(string: "http://mobileapp16.bernaschina.com/api/room/\(room)")
        }
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGesture))
        swipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipe)
    }
    
    func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.right :
            performSegue(withIdentifier: "onlineTohome", sender: self)
            break
        default:
            break
        }
    }
    
    @IBAction func btnHomePressed(_ sender: UIButton) {
        soundController.playEffect(effect: .back)
    }
    @IBAction func btnAddNewUser(_ sender: UIButton) {
        soundController.playEffect(effect: .select)
    }
    @IBAction func setSide(_ sender: UIButton) {
        
        soundController.playEffect(effect: .select)
        if isWhiteSide {
            sideFirstPlayer.setImage(UIImage(named: blackSideImage)?.withRenderingMode(.alwaysOriginal), for: .normal)
            isWhiteSide = false
        } else {
            sideFirstPlayer.setImage(UIImage(named: whiteSideImage)?.withRenderingMode(.alwaysOriginal), for: .normal)
            isWhiteSide = true
        }
    }
    
    @IBAction func editTextField(_ sender: UITextField) {
        errorLabel.isHidden = true
        sender.inputView = firstPlayerPickerView
        firstPlayerPickerView.selectRow(firstPlayerPickerView.selectedRow(inComponent: 0), inComponent: 0, animated: true)
    }
    
    @IBAction func addNewPlayer(_ sender: UIButton) {
        
        soundController.playEffect(effect: .select)
        firstPlayer.endEditing(true)
        
        let alert = UIAlertController(title: "Enter Player Name", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel))
        alert.addTextField { (configurationTextField) in
            
        }
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler:{ (UIAlertAction) in
            
            if let textField = alert.textFields?.first?.text {
                if textField.lengthOfBytes(using: .ascii) > 0 {
                    CoreDataController.shared.addPlayer(name: textField)
                    self.players = CoreDataController.shared.getAllPlayers()
                    self.firstPlayer.text = textField
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
        firstPlayer.endEditing(true)
    }
    
    @IBAction func playGame(_ sender: UIButton) {
        
        soundController.playEffect(effect: .select)
        firstPlayer.endEditing(true)
        
        guard !self.firstPlayer.text!.isEmpty else {
            errorLabel.text = "Select first player name"
            errorLabel.isHidden = false
            return
        }
        waitLabel.text = "Wait searching for an opponent"
        searchingIndicator.startAnimating()
        waitLabel.isHidden = false
        btnPlay.isEnabled = false
        searchForOpponent()
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let viewController = segue.destination as? ViewController {
            viewController.onlineGameId = onlineId
            viewController.gameUrl = gameUrl
            viewController.isOnlineGame = true
            if isWhiteSide{
                viewController.whitePlayer = firstPlayer.text!
                viewController.blackPlayer = "Online player"
                viewController.onlinePlayerColor = Color.black
            }else{
                viewController.whitePlayer = "Online player"
                viewController.blackPlayer = firstPlayer.text!
                viewController.onlinePlayerColor = Color.white
            }
        }
    }
 
    
    func searchForOpponent() {
        let session = URLSession.shared
        var request = URLRequest(url: self.url!)
        request.timeoutInterval = 30
        var json: Any?
        var serverError: Bool = false
        request.setValue("APIKey e7ad7c71-a56b-4fc6-9196-1fc6184e77e6", forHTTPHeaderField: "Authorization")
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
        
            do{
                if let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                        json = try JSONSerialization.jsonObject(with: data! as Data, options: [])
                }else {
                    serverError = true
                }
                DispatchQueue.main.async {
                    self.httpRequestComplete(json,serverError)
                }
            }catch {
               print("Connection to server failed: \(error)")
                serverError = true
                self.httpRequestComplete(json,serverError)
            }
        }
        task.resume()
    }
    
    func httpRequestComplete(_ json: Any?,_ serverError: Bool){
        
        if !serverError,
            let json = json as? [String:String] {
            gameUrl = json["url"]! as String
            onlineId = json["game"]! as String
            let color = json["color"]! as String
            if color == "white" {
                sideFirstPlayer.setImage(UIImage(named: whiteSideImage)?.withRenderingMode(.alwaysOriginal), for: .normal)
                isWhiteSide = true
            }else{
                sideFirstPlayer.setImage(UIImage(named: blackSideImage)?.withRenderingMode(.alwaysOriginal), for: .normal)
                isWhiteSide = false
            }
            waitLabel.text = "Your opponent is ready"
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                self.searchingIndicator.stopAnimating()
                self.performSegue(withIdentifier: "onlineGameSegue", sender: self)
            })
        }else if serverError {
            waitLabel.text = "Connection to server failed, please try again"
            searchingIndicator.stopAnimating()
            btnPlay.isEnabled = true
        }
    }
    
}

extension OnlineViewController: UIPickerViewDelegate {
    
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(pickerView: UIPickerView!) -> Int{
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        //player name field
        guard let players = players else { return 0 }
        return players.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard row > 0 else { return "Pick Your Name" }
        guard let players = players else { return nil }
        return players[row-1].name
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        guard row > 0 else {
            let themeColor = UIColor(red: CGFloat(55/255.0), green: CGFloat(181/255.0), blue: CGFloat(201/255.0), alpha: CGFloat(1.0))
            return NSAttributedString(string: "Pick Your Name", attributes: [NSForegroundColorAttributeName: themeColor])
        }
        guard let players = players else { return nil }
        
        var title: NSAttributedString? = nil
        if let text = players[row-1].name {
            title = NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName: UIColor.white])
        }
        
        return title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        guard row > 0 else {
            firstPlayer.text = ""
            return
        }
        if let players = players {
            firstPlayer.text = players[row-1].name
        }
    }
}
