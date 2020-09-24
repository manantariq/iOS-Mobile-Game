//
//  ViewControllerExtension.swift
//  MobileApp16
//
//  Created by Manan Tariq on 01/01/17.
//
//

import Foundation
import UIKit

extension ViewController {
    
    func getOnlinePlayerMoves() {
        self.AIActivityIndicator.startAnimating()
        let session = URLSession.shared
        var request = URLRequest(url: URL(string: self.gameUrl!)!)
        request.timeoutInterval = 30
        request.setValue("APIKey e7ad7c71-a56b-4fc6-9196-1fc6184e77e6", forHTTPHeaderField: "Authorization")

        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in

            DispatchQueue.main.async {
                self.serverGetResponse(data, response, false)
            }
        }
        task.resume()
    }
    
    func serverGetResponse(_ data: Data?,_ response: URLResponse?,_ serverError: Bool) {
        
        var json: Any?
        
        guard let serverResponse = response as? HTTPURLResponse else {
            print("error")
            getOnlinePlayerMoves()
            return
        }
        
        do{
            json = try JSONSerialization.jsonObject(with: data! , options: [])
        }catch {
            print("data error: \(error)")
        }
        
        self.AIActivityIndicator.stopAnimating()
        guard serverResponse.statusCode != 401 && serverResponse.statusCode != 410 else {
            if serverResponse.statusCode == 410 { errorAlert("Error \(serverResponse.statusCode): Game is terminated") }
            if serverResponse.statusCode == 401 { errorAlert("Error \(serverResponse.statusCode): You cannot access this room") }
            return
        }

        if serverResponse.statusCode == 200 {
            if let json = json as? [String:String] {
                let move = json["move"]! as String
                parseMoves(move)
            }else{
                errorAlert("Response is Empty")
            }
        }
        
    }
    
    func parseMoves(_ move: String){
        
        var originCoordinate: Coordinate?
        var destinationCoordinate: Coordinate?
        var error: Bool = true
        
        originCoordinate = Coordinate(Int(move[2])! - 1,Int(move[1])! - 1)
        destinationCoordinate = Coordinate(Int(move[4])! - 1,Int(move[3])! - 1)
        
        startingCoordinate = originCoordinate
        
        startingCell = getCell(coordinate: originCoordinate!)
        if (destinationCoordinate?.col)! >= 0 && (destinationCoordinate?.row)! >= 0 {
            endingCell = getCell(coordinate: destinationCoordinate!)
        }
        
        switch move[0] {
        case "M":
            if game.board.allowedMoves(coordinate: originCoordinate!).contains(destinationCoordinate!),
                doMoveAttackAction(.move) {
                error = false
            }
        case "A":
            if game.board.allowedAttacks(coordinate: originCoordinate!).contains(destinationCoordinate!),
                doMoveAttackAction(.attack) {
                error = false
            }
        case "F":
            if game.getAllowedSpellCoordinate(spell: .freeze).contains(originCoordinate!),
                doSpellAction(Action.spell(.freeze), nil) {
                error = false
            }
        case "H":
            if game.getAllowedSpellCoordinate(spell: .heal).contains(originCoordinate!),
                doSpellAction(Action.spell(.heal), nil) {
                error = false
            }
        case "R":
            //Revive spell requires a piece as a input parameter, here we set the piece to be used after in the play function
            if !(game.pieces.filter({$0.initialPosition == originCoordinate}).first == nil){
                if doSpellAction(Action.spell(.revive), game.pieces.filter({$0.initialPosition == originCoordinate}).first) {
                    error = false
                }
            }
        case "T":
            if doSpellAction(Action.spell(.teleport), nil) {
                error = false
            }
        default:
            break
        }
        if error {
            errorAlert("Move Error: \(move)")
            if isOnlineGame {
                sendDeleteRequest("invalid move")
            }
        }
    }
    
    func sendPlayerMove(_ move: String) {
        let session = URLSession.shared
        var request = URLRequest(url: URL(string: self.gameUrl!)!)
        request.timeoutInterval = 30
        request.setValue("APIKey e7ad7c71-a56b-4fc6-9196-1fc6184e77e6", forHTTPHeaderField: "Authorization")
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = move.data(using: .utf8)
        
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    DispatchQueue.main.async {
                        if !self.game.isGameEnded {
                            self.getOnlinePlayerMoves()
                        }
                    }
                }else {
                    DispatchQueue.main.async {
                        self.serverPostResponse(response,move)
                    }
                }
            }
        }
        task.resume()
    }
    
    func serverPostResponse(_ response: HTTPURLResponse?,_ move: String) {
        
        guard let response = response else {
            sendPlayerMove(move)
            return
        }
        guard response.statusCode != 410 && response.statusCode != 401 && response.statusCode != 403 else {
            if response.statusCode == 410 { errorAlert("Error \(response.statusCode): Game is terminated") }
            if response.statusCode == 401 { errorAlert("Error \(response.statusCode): You cannot access this room") }
            if response.statusCode == 403 { errorAlert("Error \(response.statusCode): It is not your turn") }
            return
        }
    }
    
    
    func sendDeleteRequest(_ msg: String){
        let session = URLSession.shared
        var request = URLRequest(url: URL(string: self.gameUrl!)!)
        request.timeoutInterval = 30
        request.setValue("APIKey e7ad7c71-a56b-4fc6-9196-1fc6184e77e6", forHTTPHeaderField: "Authorization")
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "DELETE"
        request.httpBody = msg.data(using: .utf8)
        
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
        }
        task.resume()
    }
    
    
    func completeUserMoveString(){
        
        if let startingCoordinate = startingCoordinate {
            userMove = "\(userMove)\(startingCoordinate.col + 1)\(startingCoordinate.row + 1)"
        }
        
        if let endingCoordinate = endingCell?.coordinate {
            userMove = "\(userMove)\(endingCoordinate.col + 1)\(endingCoordinate.row + 1)"
        }else{
            userMove = "\(userMove)00"
        }
        
        guard userMove.lengthOfBytes(using: .ascii) == 5 else {
            errorAlert("Move invalid format: \(userMove)")
            return
        }
        sendPlayerMove(userMove)
    }
    
    func errorAlert(_ msg: String){
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Home", style: UIAlertActionStyle.default, handler:{ (UIAlertAction) in
            self.performSegue(withIdentifier: "goToHome", sender: self)
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - Artificial Intelligence
extension ViewController {
    
    func prepareAIMove() {
        guard !game.isGameEnded else { return }
        self.AIActivityIndicator.startAnimating()
        AIWorkItem = DispatchWorkItem(qos: .userInitiated, flags: .detached) {
            self.AIMove = self.AIPlayer.nextMove(currentGame: self.game)
        }
        AIDispatchQueue.async(execute: AIWorkItem)
    }
    
    func makeAIMove() {
        self.AIWorkItem.notify(queue: .main) {
            self.AIActivityIndicator.stopAnimating()
            
            guard self.AIMove != "" else {
                print("Unexpectedly found an empty string for AI move")
                return
            }
            
            let leftCoordinates = Coordinate(Int(self.AIMove[2])!-1, Int(self.AIMove[1])!-1)
            let rightCoordinates = Coordinate(Int(self.AIMove[4])!-1, Int(self.AIMove[3])!-1)
            
            self.startingCoordinate = leftCoordinates
            self.startingCell = self.getCell(coordinate: leftCoordinates)
            if (rightCoordinates.col) >= 0 && (rightCoordinates.row) >= 0 {
                self.endingCell = self.getCell(coordinate: rightCoordinates)
            }
            
            var playDone = false
            
            //Parser della mossa
            switch self.AIMove[0] {
            case "M":
                playDone = self.doMoveAttackAction(.move)
            case "A":
                playDone = self.doMoveAttackAction(.attack)
            case "F":
                playDone = self.doSpellAction(.spell(.freeze), nil)
            case "H":
                playDone = self.doSpellAction(.spell(.heal), nil)
            case "R":
                //Revive spell requires a piece as a input parameter, here we set the piece to be used after in the play function
                let pieceToRevive = self.game.pieces.filter({ $0.initialPosition == leftCoordinates }).first
                playDone = self.doSpellAction(Action.spell(.revive), pieceToRevive)
            case "T":
                playDone = self.doSpellAction(.spell(.teleport), nil)
            default:
                return
            }
            
            if playDone {
                print("AI has played successfully")
            } else {
                print("AI tried to play an invalid move")
            }
            
            self.AIMove = ""
        }
    }
    
}
