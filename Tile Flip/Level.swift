//
//  Level.swift
//  Tile Flip
//
//  Created by Chris Hemmer on 7/3/17.
//  Copyright © 2017 Chris Hemmer. All rights reserved.
//

import Foundation
import os.log


class Level: NSObject, NSCoding{
    var name: String
    var size: Int
    var difficulty: Int
    var completed: Bool
    var locked: Bool
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("levels")
    
    struct propertyKeys{
        static let name = "name"
        static let size = "size"
        static let difficulty = "difficulty"
        static let completed = "completed"
        static let locked = "locked"
    }
    
    init?(name: String, size: Int, difficulty: Int, completed: Bool, locked: Bool){
        self.name = name
        self.size=size
        self.difficulty=difficulty
        self.completed=completed
        self.locked=locked
    }
    
    //MARK: NSCoding
    

    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: propertyKeys.name)
        aCoder.encode(size, forKey: propertyKeys.size)
        aCoder.encode(difficulty, forKey: propertyKeys.difficulty)
        aCoder.encode(completed, forKey: propertyKeys.completed)
        aCoder.encode(locked, forKey: propertyKeys.locked)
        
        
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: propertyKeys.name) as? String else{
            return nil
        }
       
        
        let size = aDecoder.decodeInteger(forKey: propertyKeys.size)
        let difficulty = aDecoder.decodeInteger(forKey: propertyKeys.difficulty)
        let completed = aDecoder.decodeBool(forKey: propertyKeys.completed)
        let locked = aDecoder.decodeBool(forKey: propertyKeys.locked)
        self.init(name: name, size: size, difficulty: difficulty, completed: completed, locked: locked)
    }
}
    
