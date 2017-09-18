//
//  GameViewController.swift
//  Tile Flip
//
//  Created by Chris Hemmer on 6/17/17.
//  Copyright © 2017 Chris Hemmer. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

import Firebase

protocol GameManager {
    func returnToMenu()
    func nextLevel()
    func gameWon()
}


class GameViewController: UIViewController, GADBannerViewDelegate, GameManager {
    
    public var numRows: Int = 5
    public var numColumns: Int = 5
    public var numShuffles: Int=1
    
    var levels = [Level]()
    
    var bannerView : GADBannerView!
    var menuButton = UIButton()
    
    var scene: GameScene = GameScene()
    var skView: SKView = SKView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait, origin: CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height))
        var bannerFrame = bannerView.frame
        bannerFrame.origin.y=self.view.bounds.height-bannerFrame.size.height
        bannerFrame.origin.x = self.view.bounds.width/2 - bannerFrame.size.width/2
        bannerView.frame=bannerFrame
                
        bannerView.adUnitID = "ca-app-pub-8981446930503360/3677448733"
        bannerView.rootViewController = self
        
        
        
        bannerView.delegate=self
        bannerView.load(GADRequest())

        
       

        if let tempLevels = loadLevels(){
            levels=tempLevels
        } else{
            //Do nothing
        }
        
        
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        
        skView.ignoresSiblingOrder = true
        skView.addSubview(bannerView)
        
        scene.scaleMode = .resizeFill
        scene.columns=numColumns
        scene.rows=numRows
        scene.shuffles=numShuffles
        scene.adHeight = bannerView.frame.height
        

        scene.menuHeight = Int(self.view.bounds.width/10)
        
        scene.gameManager=self
        skView.presentScene(scene)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
  
    
    func menuPressed(sender: UIButton!){

        scene.pause()
        
        
    }
    
    func returnToMenu(){
       performSegue(withIdentifier: "unwind", sender: self)
        

    }
    
    func nextLevel(){
        let gameVC = self.storyboard?.instantiateViewController(withIdentifier: "gameVC") as! GameViewController
        gameVC.numRows = self.numRows
        gameVC.numColumns = self.numColumns
        gameVC.numShuffles=self.numShuffles+1
        
        if gameVC.numShuffles >= 13{
            gameVC.numRows+=1
            gameVC.numColumns+=1
            gameVC.numShuffles=1
        }
        
        
        self.navigationController?.pushViewController(gameVC, animated: false)
    }

    
    private func saveLevels(){
        NSKeyedArchiver.archiveRootObject(levels, toFile: Level.ArchiveURL.path)
    }
    
    func gameWon(){
        levels[(numRows-5)*12+(numShuffles)-1].completed=true
        levels[(numRows-5)*12+(numShuffles)].locked=false
        saveLevels()
    }
    
    
    private func loadLevels() -> [Level]?{
        return NSKeyedUnarchiver.unarchiveObject(withFile: Level.ArchiveURL.path) as? [Level]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }
}
