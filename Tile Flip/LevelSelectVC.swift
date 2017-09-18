//
//  LevelSelectVC.swift
//  Tile Flip
//
//  Created by Chris Hemmer on 7/3/17.
//  Copyright © 2017 Chris Hemmer. All rights reserved.
//


import Foundation
import UIKit
import AVFoundation

class LevelSelectVC: UIViewController{
    
    public var puzzleSize = 5
    var audioPlayer = AVAudioPlayer()
    var buttonSound = Bundle.main.path(forResource: "switch6.wav", ofType: nil)
    
    public var levelButtons = [UIButton]()
    
    var levelDisplay = UIImageView()
    var backButton = UIButton()
    
    var levels = [Level]()
    
    override func viewDidLoad() {

        
        if let tempLevels = loadLevels(){

            levels=tempLevels
        } else{
            //Do nothing
        }
        
        view.backgroundColor = UIColor.black
        setUpBanner()
        setUpBackButton()
        setUpButtons()
        
    }
    
    func setUpBanner(){
        let lvlImage = UIImage(named: "Display\(puzzleSize)")!
        levelDisplay.image = lvlImage
        
        let height = view.frame.height/10
        let width = 4*height
        
        let x = (view.frame.width-width)/2
        
        levelDisplay.frame = CGRect(x: x, y: 0, width: width, height: height)
        view.addSubview(levelDisplay)
        
    }
    
    func setUpBackButton(){
        
        let width = levelDisplay.frame.width/1.5
        let height = levelDisplay.frame.height/1.5
        let x = (view.frame.width-width)/2
        let y = levelDisplay.frame.maxY * 1.1
        
        backButton.frame = CGRect(x: x, y: y, width: width, height: height)
        backButton.setImage(UIImage(named: "BackButton"), for: .normal)
        view.addSubview(backButton)
        backButton.addTarget(self, action: #selector(LevelSelectVC.back), for: .touchUpInside)
    }
    
    func setUpButtons(){
        let screenHeight = view.frame.height - levelDisplay.frame.height - backButton.frame.height
        
        
        let width = view.frame.size.width/5
        let height = width

        let temp = screenHeight - 4*height
        var i=1
        while i < 13 {
            
            let button = UIButton()
            var x: Int
            var y: Int
            if (i % 3) == 1{
                x = Int(0.5 * width)
            } else if (i % 3) == 2{
                x = Int(2 * width)
            } else{
                x = Int(3.5*width)
            }
            
            
            if i<4{
                y = Int(temp/5) + Int(levelDisplay.frame.height) + Int(backButton.frame.height)
            } else if i<7{
                y = (Int(2*temp/5)) + Int(height) + Int(levelDisplay.frame.height) + Int(backButton.frame.height)
            } else if i<10{
                y = (Int(3*temp/5)) + Int(2*height) + Int(levelDisplay.frame.height) + Int(backButton.frame.height)
            } else{
                y = (Int(4*temp/5)) + Int(3*height) + Int(levelDisplay.frame.height) + Int(backButton.frame.height)
            }
            
            button.frame = CGRect(x: x, y: y, width: Int(width), height: Int(height))
            
            if (levels[(puzzleSize-5)*12+i-1]).completed==true{
                button.setImage(UIImage(named: "Level\(i)Beaten"), for: .normal)
                
            } else if (levels[(puzzleSize-5)*12+i-1].locked==true){
                button.setImage(UIImage(named: "Level\(i)Locked"), for: .normal)
                button.isUserInteractionEnabled=false
            } else{
                button.setImage(UIImage(named: "level\(i)"), for: .normal)
            }
            
            

            button.addTarget(self, action: #selector(LevelSelectVC.levelButtonTapped(sender:)), for: .touchUpInside)
            
            
            
            button.frame = CGRect(x: x, y: y, width: Int(width), height: Int(height))
            self.view.addSubview(button)
            levelButtons.append(button)
            i=i+1
        }
    }
    
    func levelButtonTapped(sender: AnyObject){
        let button = sender as! UIButton
        let index = levelButtons.index(of: button)
        
        if (levels[(puzzleSize-5)*12+index!].locked==false){
            playSound()
            goToGame(shuffles:(index!+1))
        }
    }
    
    func playSound(){
        let url = URL(fileURLWithPath: buttonSound!)
        do{
            let sound = try AVAudioPlayer(contentsOf: url)
            audioPlayer=sound
            sound.play()
        } catch{
            //Do nothing
        }
    }
    

    func goToGame(shuffles: Int){
        let gameVC = self.storyboard?.instantiateViewController(withIdentifier: "gameVC") as! GameViewController
        
        
        
        gameVC.numRows=puzzleSize
        gameVC.numColumns=puzzleSize
        gameVC.numShuffles=shuffles
        
        self.navigationController?.pushViewController(gameVC, animated: true)
    }
    
    func back(){
        playSound()
        let menuVC = self.storyboard?.instantiateViewController(withIdentifier: "menuVC")
        
        self.navigationController?.pushViewController(menuVC!, animated: false)
        

    }
    
    private func saveLevels(){
        NSKeyedArchiver.archiveRootObject(levels, toFile: Level.ArchiveURL.path)
    }
    
    
    private func loadLevels() -> [Level]?{
        return NSKeyedUnarchiver.unarchiveObject(withFile: Level.ArchiveURL.path) as? [Level]
    }
}
