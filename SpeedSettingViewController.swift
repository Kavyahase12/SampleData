//
//  SpeedSettingViewController.swift
//  EPOCHBLE1
//
//  Created by MAC Developers on 20/04/2017.
//  Copyright © 2017 MAC Developers. All rights reserved.
//

import UIKit

class SpeedSettingViewController: UIViewController {

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
    }
    
    
    
    func SwipeRightGesture(gesture: UISwipeGestureRecognizer)
    {
                print("Right swapped")
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func onSetBtn(_ sender: Any) {
        
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
