//
//  GameScene.swift
//  Tile Flip
//
//  Created by Chris Hemmer on 6/17/17.
//  Copyright © 2017 Chris Hemmer. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreGraphics
import UIKit
import Firebase
import AVFoundation


class GameScene: SKScene{
    var gameManager:GameManager?
   
    //Setting up the tiles
    var tile1: SKTileDefinition = SKTileDefinition(texture: SKTexture(imageNamed: "NumberTile1"))
    var tile2: SKTileDefinition = SKTileDefinition(texture: SKTexture(imageNamed: "NumberTile2"))
    var tile3: SKTileDefinition = SKTileDefinition(texture: SKTexture(imageNamed: "NumberTile3"))
    var tile1Group: SKTileGroup = SKTileGroup()
    var tile2Group: SKTileGroup = SKTileGroup()
    var tile3Group: SKTileGroup = SKTileGroup()
    var tempTexture: SKTexture = SKTexture()
    var tilesSet: SKTileSet = SKTileSet()
    
    var ints = [Int]()
    
    let gameLayer = SKNode()
    let pauseLayer = SKNode()
    var victoryBackground = SKSpriteNode()
    
    var gameWon = Bool()
    
    //Variables from VC
    public var rows: Int=5
    public var columns: Int=5
    public var shuffles: Int=1
    public var adHeight: CGFloat=0
    public var menuHeight: Int=200
    
    var menu = SKSpriteNode()
    var pauseButton = SKSpriteNode()
    var pauseMenu = SKScene()
    var cancelButton = SKSpriteNode()
    var confirmButton = SKSpriteNode()
    var victory = SKSpriteNode()
    var menuButton = SKSpriteNode()
    var nextButton = SKSpriteNode()
    
    var tileMap: SKTileMapNode = SKTileMapNode()
    
    
    //Sound
    let coinSound = SKAction.playSoundFileNamed("rollover3.wav", waitForCompletion: false)
    let buttonSound = SKAction.playSoundFileNamed("switch6.wav", waitForCompletion: false)
    let victorySound = SKAction.playSoundFileNamed("powerUp7.mp3", waitForCompletion: false)
    let victorySound2 = SKAction.playSoundFileNamed("powerUp4.mp3", waitForCompletion: false)
    
    
    override func didMove(to view: SKView) {
        view.backgroundColor = UIColor.cyan
        
        
        tile1Group = SKTileGroup(tileDefinition: tile1)
        tile2Group = SKTileGroup(tileDefinition: tile2)
        tile3Group = SKTileGroup(tileDefinition: tile3)
        
        tilesSet = SKTileSet(tileGroups: [tile1Group, tile2Group, tile3Group])
        tempTexture = SKTexture(imageNamed: "NumberTile1")
        
        menu = SKSpriteNode(color: UIColor.black, size: CGSize(width: Int(self.size.width), height: menuHeight))
        
        menu.position = CGPoint(x: Int(self.size.width)/2, y: Int(self.size.height)-menuHeight/2)
        menu.zPosition=2
        gameLayer.addChild(menu)
        
      
        pauseButton = SKSpriteNode(imageNamed: "Menu2")
        pauseButton.position = CGPoint(x: Int(self.size.width/2), y: Int(self.size.height)-menuHeight/2)
        pauseButton.zPosition=3
        pauseButton.yScale = CGFloat(menuHeight)/pauseButton.frame.height
        pauseButton.xScale=2.0*pauseButton.yScale
        gameLayer.addChild(pauseButton)
      
        
        for _ in 0..<rows*columns{
            let num = 2
            ints.append(num)
        }
        
        
        

        
        
 
        
        var x=0
        
        for _ in 0..<shuffles*rows*5{

            x=x+1
            let num = Int(arc4random_uniform(UInt32(rows*columns)))

            updateTileData(index: num, playing: false)
        }
        
        updateTiles()
        self.addChild(gameLayer)
      
        gameWon=false
        
        
    }
  
    
    
    
    func updateTiles(){
        
       tileMap.removeFromParent()
        
        let tempTexture = SKTexture(imageNamed: "NumberTile1")
        
        
        tileMap = SKTileMapNode(tileSet: tilesSet, columns: columns, rows: rows, tileSize: tempTexture.size())
        tileMap.anchorPoint = CGPoint(x: 0, y: 0)
        tileMap.position  = CGPoint(x: 0, y: Int(adHeight))
        
        let temp = self.size.height-adHeight-CGFloat(menuHeight)
        tileMap.xScale = CGFloat(self.size.width/CGFloat(tempTexture.size().height*CGFloat(rows)))
        tileMap.yScale = CGFloat(temp/CGFloat(tempTexture.size().height*CGFloat(rows)))
        
        for x in 0..<columns{
            for y in 0..<rows{
                if (ints[x+(y*rows)]==1){
                    tileMap.setTileGroup(tile1Group, forColumn: x, row: y)
                } else if (ints[x+(y*rows)]==2){
                    tileMap.setTileGroup(tile2Group, forColumn: x, row: y)
                } else if (ints[x+(y*rows)]==3){
                    tileMap.setTileGroup(tile3Group, forColumn: x, row: y)
                }
                
                
            }
        }
        gameLayer.addChild(tileMap)


    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        
        for touch in touches{
            if gameLayer.isPaused==false{
                let positionInScene = touch.location(in: gameLayer)
            
                if tileMap.contains(positionInScene) && !gameWon{
                    let location = touch.location(in: tileMap)
            
            
                    let touchRow = tileMap.tileRowIndex(fromPosition: location)
                    let touchColumn = tileMap.tileColumnIndex(fromPosition: location)
                    let index = touchColumn + (touchRow*rows)
                    run(coinSound)
            
                    updateTileData(index: index, playing: true)
                } else if pauseButton.contains(positionInScene){
                    run(buttonSound)
                    pause()
                } else if menuButton.contains(positionInScene){
                    gameManager?.returnToMenu()
                    run(buttonSound)
                } else if nextButton.contains(positionInScene){
                    gameManager?.nextLevel()
                    run(buttonSound)
                }
            } else{
                let positionInScene = touch.location(in: pauseLayer)
                
                if cancelButton.contains(positionInScene){
                    run(buttonSound)
                    unpause()
                } else if confirmButton.contains(positionInScene){

                    run(buttonSound)
                    gameManager?.returnToMenu()
                }
            }
        }
    }
    
    func updateTileData(index: Int, playing: Bool){
        
        var adjacents = [Int]()
        adjacents.append(index+rows)
        adjacents.append(index-rows)
        adjacents.append(index+1)
        adjacents.append(index-1)
        
        adjacents.append(index+rows+1)
        adjacents.append(index+rows-1)
        adjacents.append(index-rows+1)
        adjacents.append(index-rows-1)
        
        ints[index]+=1
        
        if ints[index]==4{
            ints[index]=1
        }
        
        
        var x=0;
        let size = adjacents.count

        while(x<size){
            
            if (adjacents[x]>=0 && adjacents[x]<=rows*columns-1){
                if (index%rows==rows-1 && adjacents[x]%rows==0){
                    x+=1
                    continue
                } else if (index%rows==0 && adjacents[x]%rows==rows-1){
                    x+=1
                    continue
                } else{
                    ints[adjacents[x]]+=1
                    if ints[adjacents[x]]==4{
                        ints[adjacents[x]]=1
                    }
                }
            }
            x+=1
            
            
        }
        
        if playing{
            updateTiles()
        }
        
        
        if (playing && testForVictory()){
            levelBeat()
        }

    }
    
    
    
    func levelBeat(){
        run(victorySound)
        run(victorySound2)
        victory = SKSpriteNode(imageNamed: "Victory")
        let height = victory.size.height
        let width = victory.size.width
        victory.position = CGPoint(x: self.size.width/2, y: self.size.height/1.5)
        victory.xScale=CGFloat(self.size.width/(1.25*width))
        victory.yScale=CGFloat(self.size.height/(4*height))
        victory.zPosition=2
        gameLayer.addChild(victory)
        
        
        menuButton = SKSpriteNode(imageNamed: "Menu")
        menuButton.position = CGPoint(x: self.size.width/2, y: victory.position.y - (0.9*victory.size.height))
        menuButton.xScale=victory.xScale
        menuButton.yScale=victory.yScale/1.5
        menuButton.zPosition=2
        gameLayer.addChild(menuButton)
        
        if (rows != 10 && columns != 10){
            nextButton = SKSpriteNode(imageNamed: "Next")
            nextButton.position = CGPoint(x: self.size.width/2, y: menuButton.position.y - (1.1*menuButton.size.height))
            nextButton.xScale=menuButton.xScale
            nextButton.yScale=menuButton.yScale
            nextButton.zPosition=2
            gameLayer.addChild(nextButton)
        }
        
        victoryBackground = SKSpriteNode()
        victoryBackground.size = self.size
        victoryBackground.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        victoryBackground.color = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.75)
        victoryBackground.zPosition = 1
        gameLayer.addChild(victoryBackground)
        
        
        gameWon=true
        
        gameManager?.gameWon()
        pauseButton.removeFromParent()
    }
    
    func testForVictory() -> Bool{
        let firstNum = ints[0]
        for x in ints{
            if !(x==firstNum){
                return false
            }
        }
        return true
    }
    
    func pause(){
        pauseButton.removeFromParent()
        gameLayer.isPaused=true
        
        let pauseNode = SKSpriteNode()
        
        
        //Background
        pauseNode.size = CGSize(width: self.size.width, height: self.size.height)
        pauseNode.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        pauseNode.color = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3)
        
       //Returns you to game
        cancelButton = SKSpriteNode(imageNamed: "BackToGame")
        cancelButton.size = CGSize(width: self.size.width/2, height: self.size.width/4)
        cancelButton.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        
        //Returns you to menu
        confirmButton = SKSpriteNode(imageNamed: "BackToMenu")
        confirmButton.size = CGSize(width: self.size.width/2, height: self.size.width/4)
        confirmButton.position = CGPoint(x: self.size.width/2, y: self.size.height/2 + (1.25*confirmButton.size.height))
        

        
        pauseLayer.addChild(pauseNode)
        pauseLayer.addChild(cancelButton)
        pauseLayer.addChild(confirmButton)
        pauseLayer.zPosition=5
        
        self.addChild(pauseLayer)
    }
    
    func unpause(){
        gameLayer.isPaused=false
        pauseLayer.removeFromParent()
        pauseLayer.removeAllChildren()
        gameLayer.addChild(pauseButton)
    }
    
   
}


