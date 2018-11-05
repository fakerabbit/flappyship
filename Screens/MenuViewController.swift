//
//  MenuViewController.swift
//  FlappyShip
//
//  Created by Mirko Justiniano on 11/4/18.
//  Copyright © 2018 idevcode. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    fileprivate var v: MenuView?
    
    // MARK: View methods
    
    override func loadView() {
        super.loadView()
        // Configure the view.
        v = MenuView(frame: UIScreen.main.bounds)
        self.view = v!;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask(rawValue: UInt(Int(UIInterfaceOrientationMask.allButUpsideDown.rawValue)))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}
