//
//  MenuViewController.swift
//  FlappyShip
//
//  Created by Mirko Justiniano on 11/4/18.
//  Copyright © 2018 idevcode. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, MenuViewDelegate {
    
    fileprivate var v: MenuView?
    
    // MARK: View methods
    
    override func loadView() {
        super.loadView()
        // Configure the view.
        v = MenuView(frame: UIScreen.main.bounds)
        v?.menuDelegate = self
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
    
    // MARK: MenuViewDelegate methods
    
    func MenuViewOnPlay(_ view: MenuView) {
        let controller: GameViewController = GameViewController()
        let appDel = UIApplication.shared.delegate! as! AppDelegate
        appDel.navController?.popViewController(animated: false)
        appDel.navController?.pushViewController(controller, animated: true)
        appDel.navController?.viewControllers = [controller]
    }
    
    func MenuViewOnPlay2(_ view: MenuView) {
        let controller: ParallaxViewController = ParallaxViewController()
        let appDel = UIApplication.shared.delegate! as! AppDelegate
        appDel.navController?.popViewController(animated: false)
        appDel.navController?.pushViewController(controller, animated: true)
        appDel.navController?.viewControllers = [controller]
    }
}
