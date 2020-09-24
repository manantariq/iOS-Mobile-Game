//
//  CoreDataController.swift
//  MobileApp16
//
//  Created by Manan Tariq on 14/12/16.
//
//

import Foundation
import CoreData
import UIKit


class CoreDataController {
    
    static let shared = CoreDataController()
    
    private var context: NSManagedObjectContext
    
    private init() {
        let application = UIApplication.shared.delegate as! AppDelegate
        self.context = application.persistentContainer.viewContext
    }
    
    /// save new player in core data
    ///
    /// - Parameters:
    ///   - name: player name
    func addPlayer(name: String) {
        
        guard getPlayerByName(name) == nil else { return }
        
        let entity = NSEntityDescription.entity(forEntityName: "PlayerStatistic", in: self.context)
        let player = PlayerStatistic(entity: entity!, insertInto: self.context)
        
        player.name = name.capitalized
        
        do {
            try self.context.save()
        } catch  {
            print("[CDC] Error while trying to save player: \(error)")
        }
    }
    
    /// search player with name
    ///
    /// - Parameter name: player name
    /// - Returns: player object
    func getPlayerByName(_ name: String) -> PlayerStatistic? {
        
        let fetchRequest: NSFetchRequest<PlayerStatistic> = PlayerStatistic.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        
        let predicate = NSPredicate(format: "name = %@", name)
        fetchRequest.predicate = predicate
        
        if let players = self.fetchRequest(request: fetchRequest) {
            guard players.count > 0 else {
                return nil
            }
            return players.first
        }
        return nil
    }
    
    
    /// get all players save in core data
    ///
    /// - Returns: array of players
    func getAllPlayers() -> [PlayerStatistic]? {
        
        let request: NSFetchRequest<PlayerStatistic> = NSFetchRequest(entityName: "PlayerStatistic")
        request.returnsObjectsAsFaults = false
        
        let sortDescriptor = NSSortDescriptor(key: "win", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        if let players = self.fetchRequest(request: request) {
            return players
        }
        return nil
    }
    
    /// delete a player
    ///
    /// - Parameter name: player name
    func deletePlayer(_ name: String) {
        if let player = getPlayerByName(name) {
            self.context.delete(player)
        }
        do {
            try self.context.save()
        } catch let errore {
            print("[CDC] Error while trying to delete the player")
            print("  Stampo l'errore: \n \(errore) \n")
        }
    }
    
    /// update player statistics
    ///
    /// - Parameter name: player name
    func updatePlayer(_ name: String, _ whiteSide: Int, _ darkSide: Int, _ win: Int, _ lost: Int){
        
        if let player = getPlayerByName(name) {
            player.whiteSide += Int32(whiteSide)
            player.darkSide += Int32(darkSide)
            player.win += Int32(win)
            player.lost += Int32(lost)
            player.total += Int32(1)
            
            do {
                try player.managedObjectContext?.save()
            } catch let errore {
                print("[CDC] Error while trying to update the player")
                print("  Stampo l'errore: \n \(errore) \n")
            }
        }
    }
    
    /// update user tutorial flag
    ///
    /// - Parameters:
    ///   - name: player name
    ///   - flag: true mean new player so show the tutorial
    func updatePlayerTutorialFlag(_ name: String,_ flag: Bool) {
        
        if let player = getPlayerByName(name) {
            player.tutorial = flag
            do {
                try player.managedObjectContext?.save()
            } catch let errore {
                print("[CDC] Error while trying to update the player")
                print("  Stampo l'errore: \n \(errore) \n")
            }
        }
    }
    
    /// execute the query 
    private func fetchRequest(request: NSFetchRequest<PlayerStatistic>) -> [PlayerStatistic]? {
        
        var players = [PlayerStatistic]()
        
        do {
            players = try self.context.fetch(request)
            return players
        } catch {
            print("[CDC] Error while trying to fetch the request: \(error)")
            return nil
        }
    }
    
    
    /// add new match
    ///
    /// - Parameters:
    ///   - playerOne: first player name
    ///   - playerTwo: second player name
    ///   - won: who won the game
    func addNewMatch(_ playerOne: String, _ playerTwo: String, _ winner: String, _ turns: Int) {
        
        let entity = NSEntityDescription.entity(forEntityName: "MatchStatistic", in: self.context)
        let match = MatchStatistic(entity: entity!, insertInto: self.context)
        match.playerOne = playerOne
        match.playerTwo = playerTwo
        match.winner = winner
        match.turns = Int32(turns)
        match.date = Date() as NSDate?
        
        do {
            try self.context.save()
        } catch  {
            print("[CDC] Error while trying to save match: \(error)")
        }
    }
    
    
    /// return all matches
    ///
    /// - Returns: array of matches
    func getAllMatches() -> [MatchStatistic]? {
        
        let request: NSFetchRequest<MatchStatistic> = NSFetchRequest(entityName: "MatchStatistic")
        request.returnsObjectsAsFaults = false
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        if let matches = self.fetchMatchRequest(request: request) {
            return matches
        }
        return nil
    }
    
    
    /// search a match's statistics with id
    ///
    /// - Parameter objectID: match id
    /// - Returns: return match's statistics
    func getMatchById(_ objectID: NSManagedObjectID) -> MatchStatistic? {
        
        do {
            return try context.existingObject(with: objectID) as? MatchStatistic
        } catch {
            print("[CDC] Error while trying to fetch the request: \(error)")
            return nil
        }
    }
    
    func deleteMatch(_ objectID: NSManagedObjectID) {
        if let match = getMatchById(objectID) {
            self.context.delete(match)
        }
        do {
            try self.context.save()
        } catch let errore {
            print("[CDC] Error while trying to delete the match")
            print("  Stampo l'errore: \n \(errore) \n")
        }
    }
    
    /// execute the query
    private func fetchMatchRequest (request: NSFetchRequest<MatchStatistic>) -> [MatchStatistic]? {
    
        do {
            return try self.context.fetch(request)
        } catch {
            print("[CDC] Error while trying to fetch the request: \(error)")
            return nil
        }
    }
    
    
    /// set default app settings
    func setAppSettings(){
        guard getAppSettings() == nil else { return }
        
        let entity = NSEntityDescription.entity(forEntityName: "AppSettings", in: self.context)
        let settings = AppSettings(entity: entity!, insertInto: self.context)
        settings.music = true
        settings.sounds = true
        settings.serverRoom = "public"
        do {
            try self.context.save()
        } catch  {
            print("[CDC] Error while trying to save app settings: \(error)")
        }

    }
    
    
    /// return app settings
    ///
    /// - Returns: array of settings
    func getAppSettings() -> AppSettings? {
        
        let request: NSFetchRequest<AppSettings> = NSFetchRequest(entityName: "AppSettings")
        request.returnsObjectsAsFaults = false
        
        if let settings = self.fetchSettingRequest(request: request)?.first {
            return settings
        }
        return nil
    }
    
    
    /// update app settings
    ///
    /// - Parameters:
    ///   - music: app music
    ///   - sounds: app sounds
    ///   - serverRoom: Server Room to use for online game
    func updateAppSettings(_ music: Bool?,_ sounds:Bool?,_ serverRoom: String?,_ tutorial: Bool?) {
        
        if let settings = getAppSettings() {
            if let music = music { settings.music = music }
            if let sounds = sounds { settings.sounds = sounds }
            if let serverRoom = serverRoom { settings.serverRoom = serverRoom }
            if let tutorial = tutorial { settings.tutorial = tutorial }
            
            do {
                try settings.managedObjectContext?.save()
            } catch let errore {
                print("[CDC] Error while trying to update app settings")
                print("  Stampo l'errore: \n \(errore) \n")
            }
        }
    }
    
    /// execute the query
    private func fetchSettingRequest (request: NSFetchRequest<AppSettings>) -> [AppSettings]? {
        
        do{
            return try self.context.fetch(request)
        }catch {
            print("[CDC] Error while trying to fetch the request: \(error)")
            return nil
        }
    }
        
}
