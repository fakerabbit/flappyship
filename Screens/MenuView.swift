//
//  MenuView.swift
//  FlappyShip
//
//  Created by Mirko Justiniano on 11/4/18.
//  Copyright © 2018 idevcode. All rights reserved.
//

import UIKit
import SpriteKit

/*
 * Hermes
 Hermes-Regular
 */

protocol MenuViewDelegate: class {
    func MenuViewOnPlay(_ view: MenuView)
}

class MenuView: SKView {
    
    // MARK: Delegate
    
    weak var menuDelegate: MenuViewDelegate?
    
    // MARK: Variables
    
    let pad: CGFloat = 30.0
    let tpad: CGFloat = 10.0
    let buttonH: CGFloat = 30.0
    let buttonW: CGFloat = 100.0
    
    fileprivate var cscene: SKScene?
    
    fileprivate var playBtn: UIButton?,
                    logoIv: UIImageView?
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //self.printFontNamesInSystem()
        
        cscene = SKScene(size: self.bounds.size)
        //scene.backgroundColor = UIColor.clearColor()
        cscene?.scaleMode = .resizeFill
        
        self.fillBackground()
        
        logoIv = UIImageView(image: UIImage(named: "Logo"))
        logoIv?.contentMode = UIView.ContentMode.scaleAspectFit
        self.addSubview(logoIv!)
        
        playBtn = UIButton(frame: CGRect.zero)
        playBtn?.setTitle("Play", for: .normal)
        playBtn?.titleLabel?.font = UIFont(name: "Hermes-Regular", size: 52)
        playBtn?.setTitleColor(UIColor(red: 255/255, green: 111/255, blue: 60/255, alpha: 1), for: .normal)
        playBtn?.setTitleColor(UIColor(red: 255/255, green: 201/255, blue: 60/255, alpha: 1), for: .highlighted)
        //playBtn?.setImage(UIImage(named: "Arcade"), for: UIControl.State())
        //playBtn?.setImage(UIImage(named: "ArcadeOn"), for: .highlighted)
        playBtn?.sizeToFit()
        playBtn?.contentMode = .scaleAspectFit
        playBtn?.addTarget(self, action: #selector(MenuView.onPlay(_:)), for: .touchUpInside)
        self.addSubview(playBtn!)
        
        self.presentScene(cscene)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let w = self.frame.size.width,
        h = self.frame.size.height
        
        if w <= 0 || h <= 0 {
            return
        }
        
        logoIv?.frame = CGRect(x: pad, y: 50, width: w - pad * 2, height: logoIv!.frame.size.height)
        playBtn?.frame = CGRect(x: w/2 - playBtn!.frame.size.width/2, y: h/2 - playBtn!.frame.size.height/2, width: playBtn!.frame.size.width, height: playBtn!.frame.size.height)
    }
    
    // MARK: Public methods
    
    @objc func onPlay(_ sender: UIButton?) {
        //cscene?.run(clickSound)
        menuDelegate?.MenuViewOnPlay(self)
    }
    
    // MARK: Private methods
    
    fileprivate func fillBackground() {
        
        let tile = SKTexture(imageNamed: "BgTile")
        var totH: CGFloat = 0
        var totW: CGFloat = 0
        var i: Int = 0
        var j: Int = 0
        
        while totH < UIScreen.main.bounds.size.height + tile.size().height {
            
            if totW >= UIScreen.main.bounds.size.width {
                totW = 0
                i = 0
            }
            
            while totW < UIScreen.main.bounds.size.width + tile.size().width {
                let bg = SKSpriteNode(texture: tile)
                bg.zPosition = -100
                bg.position = CGPoint(x: CGFloat(i) * tile.size().width, y: CGFloat(j) * tile.size().height)
                cscene?.addChild(bg)
                i += 1
                totW += tile.size().width
            }
            
            j += 1
            totH += tile.size().height
        }
    }
    
    fileprivate func printFontNamesInSystem() {
        for family in UIFont.familyNames {
            print("*", family);
            
            for name in UIFont.fontNames(forFamilyName: family ) {
                print(name);
            }
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
