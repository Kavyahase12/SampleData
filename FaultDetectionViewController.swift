//
//  FaultDetectionViewController.swift
//  EPOCHBLE1
//
//  Created by MAC Developers on 20/04/2017.
//  Copyright © 2017 MAC Developers. All rights reserved.
//

import UIKit

class FaultDetectionViewController: UIViewController,UIGestureRecognizerDelegate {

    @IBOutlet var faultView: UIView!
    
    
    
    @IBAction func rightGesture(_ sender: UISwipeGestureRecognizer) {
   
    
        self.dismiss(animated: true, completion: nil)

    }
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        let swipegesture = UISwipeGestureRecognizer.init(target: self, action: Selector(("handleGesture")))
        swipegesture.direction=UISwipeGestureRecognizerDirection.left
        self.faultView.addGestureRecognizer(swipegesture)
        
        


    }
    func handleGesture(sender:UISwipeGestureRecognizer)
    {
        print("fault")

        self.dismiss(animated: true, completion: nil)
        
        
        
    }
    func handleGesture1(sender:UISwipeGestureRecognizer?=nil)
    {
        
        self.dismiss(animated: true, completion: nil)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
