//
//  menuVC.swift
//  Tile Flip
//
//  Created by Chris Hemmer on 6/20/17.
//  Copyright © 2017 Chris Hemmer. All rights reserved.
//


import Foundation
import UIKit
import AVFoundation
import os.log


class menuVC: UIViewController {
    
    
    @IBOutlet weak var backgroundImage: UIImageView!
   
    var audioPlayer = AVAudioPlayer()
    var buttonSound = Bundle.main.path(forResource: "switch6.wav", ofType: nil)
    var levels = [Level]()
    
    var titleImage = UIImageView()
    var levelSelectImage = UIImageView()
    
    var firstLoad = true
    
    var buttons = [UIButton]()
    
    var myHeight: CGFloat = 1.0
    var myWidth: CGFloat = 1.0
    var minY: CGFloat = 1.0
    var maxY: CGFloat = 1.0
    var minX: CGFloat = 1.0
    var maxX: CGFloat = 1.0
    
    var notificationCenter = NotificationCenter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToFront), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        
        
        myHeight = (view.frame.height/9)*7
        myWidth = (view.frame.width/9)*7
        minY = view.frame.height/9
        maxY = (view.frame.height/9)*8
        minX = view.frame.width/9
        maxX = (view.frame.width/9)*8
       
        
        setUpButtons()
        setUpLevelSelect()
        
        if let savedLevels = loadLevels(){

            levels = savedLevels
        } else{
            levelSetUp()
        }
        
        backgroundImage.animationDuration = TimeInterval(30.0)
        backgroundImage.animationImages = []
        
        var x=1
        
        while (x<38){
            backgroundImage.animationImages?.append(UIImage(named: "\(x)")!)
            x=x+1
        }
        
        backgroundImage.startAnimating()
        
        
        titleImage.image = UIImage(named: "Title")
        titleImage.frame = CGRect(x: minX, y: 0.5*minY, width: myWidth*0.9, height: myHeight/2)
        let width = titleImage.frame.width
        let height = titleImage.frame.height
        titleImage.frame = CGRect(x: minX+(myWidth-width)/2, y: 1.2*minY, width: width, height: height)
        self.view.addSubview(titleImage)
     
     
        saveLevels()
    }
    
    
    func appMovedToBackground(){
        backgroundImage.stopAnimating()
        
        backgroundImage.image = UIImage(named: "1")
        
        
    }
    
    func appMovedToFront(){
        backgroundImage.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
       super.viewDidAppear(animated)
        
        if (firstLoad==false){
            if let savedLevels = loadLevels(){
                
                levels = savedLevels
            } else{
                
                levelSetUp()
            }
        }
 
    }
    
    func setUpButtons(){
        var i=10
        let width = Int(myWidth)/3

        let height = Int(view.frame.height)/12


        
        
        while i >= 5 {
            var x: Int
            var y: Int
            
            if i%2==0{
                x=Int(minX) + (Int(myWidth)/9)*5
            } else{
                x=Int(minX)+Int(myWidth)/9
            }
            
            if i>8{
                y=Int(maxY) - height - height/5
            } else if i>6{
                y=Int(maxY) - 2*height - 2*(height/5)
            } else{
                y=Int(maxY) - 3*height - 3*(height/5)
            }
            
            let button = UIButton()
            button.frame = CGRect(x: x, y: y, width: width, height: height)
            let image = UIImage(named: "select\(i)")
          
            

            button.setImage(image, for: .normal)

            button.addTarget(self, action: #selector(menuVC.goToGame(sender:)), for: .touchUpInside)
            buttons.append(button)
            self.view.addSubview(button)
            i-=1
        }
    }
    
    func setUpLevelSelect(){

        levelSelectImage.image = UIImage(named: "LevelSelect")
        levelSelectImage.frame = CGRect(x: 0.0, y: 0.0, width: 0.75*myWidth, height: 0.25*myWidth)
        let width = levelSelectImage.frame.width
        let height = levelSelectImage.frame.height
        levelSelectImage.frame = CGRect(x: minX+(myWidth-width)/2, y: buttons[5].frame.minY-0.8*height, width: width, height: height)

        self.view.addSubview(levelSelectImage)
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

    
    func goToGame(sender: AnyObject){
        saveLevels()
        playSound()
        
        let button = sender as? UIButton
        let index = buttons.index(of: button!)
        let size = 10-index!
        
        firstLoad=false
        let levelVC = self.storyboard?.instantiateViewController(withIdentifier: "LevelSelectVC") as! LevelSelectVC
        levelVC.puzzleSize = size
        
        self.navigationController?.pushViewController(levelVC, animated: true)
    }
    
    @IBAction func UnwindToMenu(sender: UIStoryboardSegue){
        
    }
    
    private func saveLevels(){
        NSKeyedArchiver.archiveRootObject(levels, toFile: Level.ArchiveURL.path)

    }
    
    
    private func loadLevels() -> [Level]?{

        return NSKeyedUnarchiver.unarchiveObject(withFile: Level.ArchiveURL.path) as? [Level]
    }
    
 
    private func levelSetUp(){
        var x = 5
        
        while x<11{
            var y = 1
            while y<13{
                if (y==1){
                    let level = Level.init(name: "\(x) \(y)", size: x, difficulty: 1, completed: false, locked: false)
                    self.levels.append(level!)
                } else{
                    let level = Level.init(name: "\(x) \(y)", size: x, difficulty: y, completed: false, locked: true)
                    self.levels.append(level!)
                }
                y=y+1
            }
            x=x+1
        }
    }
    
    
}

