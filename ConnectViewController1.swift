//
//  connectViewController.swift
//  EPOCHBLE
//
//  Created by MAC Developers on 24/03/2017.
//  Copyright © 2017 MAC Developers. All rights reserved.
//

import UIKit
import Foundation
import CoreBluetooth

class connectViewController: UIViewController,UITextFieldDelegate,UIGestureRecognizerDelegate{
    
      
    @IBOutlet weak var speedLabel: UILabel!
    
    @IBOutlet weak var rpmLabel: UILabel!
    @IBOutlet weak var txtSpeed: UITextField!
    
    @IBOutlet weak var setSpeedbtn: UIButton!
    
    @IBOutlet weak var wirelessBlink: UIImageView!
    
    
    @IBOutlet weak var stopMotor: UIButton!
    @IBOutlet weak var motorStartBtn: UIButton!
    var checked = false

    let asciiToHex:[UInt8]=[0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x40,0x41,0x42,0x43]
    var  bluetoothPeripheral : CBPeripheral?

    var set_SpeedFrame:[UInt8]=[0x52,0x0,0x0,0x0,0x0,0x0,0x0,0x0]
   
    let firstDigit=[UInt16]()
    let TwoDigit=[UInt16]()
    let ThreeDigit=[UInt16]()
    var FourDigit=[UInt16]()
    
    var speedZero = UInt8()
    var speedOne = UInt8()
    var speedTwo = UInt8()
    var speedThree = UInt8()
    var speedFour = UInt8()
    var speedFive = UInt8()
    
    var Speed_Zero = UInt16()
    var Speed_One=UInt16()
    var Speed_Two = UInt16()
    var Speed_Three = UInt16()
    var Speed_Four = UInt16()
    var Speed_Five = UInt16()
    
     var Speed_Value = UInt16()
    var sendValueStore = String()
    
   let motorStartArray : [UInt8] = [ 0x55, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
    fileprivate var uartRXCharacteristic        : CBCharacteristic?
    fileprivate var uartTXCharacteristic        : CBCharacteristic?

    
    @IBOutlet var firstMainView: UIView!
    struct globalVariable6
    {
        static  var receivedDataArray:[Int]=[]
        //static var speed6 = [String!]()
        static var getSpeedZero=UInt8()
        static var getSpeedOne=UInt8()
        static var getSpeedTwo=UInt8()
        static var getSpeedThree=UInt8()
        static var getSpeedFour=UInt8()
        static var getSpeedFive=UInt8()
        static var getSpeedValue=UInt8()
        static var sendValueStorebool:[Bool]=[true]
   }
    
    
  
    override func viewDidLoad()
    {
        super.viewDidLoad()
       // onButtonOneClick()
        txtSpeed.delegate=self
   
   //     txtSpeed.font=UIFont(name:"Aerial",size: 71.0)
      speedLabel.font=UIFont(name:"Californian FB",size:22)
        rpmLabel.font=UIFont(name:"Californian FB",size:22)
        txtSpeed.font=UIFont(name:"Californian FB",size:101)
        speedLabel.font=UIFont(name:"Californian FB",size:22)
            //  let swipegesture=UISwipeGestureRecognizer(target(forAction: Selector(("handleGesture"), withSender: self))
      
        }
    
    @IBAction func leftGesture(_ sender: UISwipeGestureRecognizer)
    {
        
        
        
        print("omnnect")
        
        let storyboard=UIStoryboard(name:"Main",bundle:nil)
        let scannerViewController = storyboard.instantiateViewController(withIdentifier: "FaultDetectionViewController")
        self.present(scannerViewController, animated: true, completion: nil)

  
        

        
    
    
    }
    
    @IBAction func OnPlease(_ sender: Any) {
              //connectView.send(text: "")
        let storyboard=UIStoryboard(name:"Main",bundle:nil)
        let connectView:ScannerViewController = storyboard.instantiateViewController(withIdentifier: "ScannerViewController") as! ScannerViewController
        
        connectView.stopMotor(text: "")

          
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        txtSpeed.resignFirstResponder()
        return true
    }
    
    
    
    
    @IBAction func onConnectBtn(_ sender: UIButton)
    {
       
        
    //_ = Timer.scheduledTimer(timeInterval:0.250, target: self, selector:  #selector(connectViewController.onConnectBtn(_:)), userInfo: nil, repeats: true)
    /*
        self.speedZero = connectViewController.globalVariable6.getSpeedZero
        print("speedZero \(speedZero)")
        
        self.speedOne = connectViewController.globalVariable6.getSpeedOne
        print("speedOne \(speedOne)")
        
        self.speedTwo = connectViewController.globalVariable6.getSpeedTwo
        print("speedTwo \(speedTwo)")
        
        self.speedThree = connectViewController.globalVariable6.getSpeedThree
        print("speedThree \(speedThree)")
        
        self.speedFour = connectViewController.globalVariable6.getSpeedFour
        print("speedFour \(speedFour)")
        
        self.speedFive = connectViewController.globalVariable6.getSpeedFive
        print("speedFive \(speedFive)")
        
        
        // let priority = DispatchQueue.GlobalQueuePriority.default
        // do some task
        
        // update some UI
        
        DispatchQueue.main.async(execute:
            {
                // Update UI
                if(self.speedZero==0x3f)
                {
                    if(self.speedThree==0x20)
                    {
                        //  self.speedLabel.text = String(self.speedThree)
                        //   speedOne=
                     
                        self.Speed_One = UInt16( self.asciiToHex.index(of:self.speedOne)!)
                        print("SPEEDVALUE \(self.Speed_One)")
                        self.Speed_Two = UInt16(UInt8(self.asciiToHex.index(of: self.speedTwo)!))
                        let speedValue = self.Speed_One*10 + self.Speed_Two
                        
                        self.txtSpeed.text=(String(speedValue))
                        print("SPEEDVALUE \(speedValue)")
                    }
                    else
                    {
                        if(self.speedTwo==0x20)
                        {
                            
                            self.Speed_One = UInt16(UInt8((self.asciiToHex.index(of: self.speedOne))!))
                            self.txtSpeed.text=(String(self.speedOne))
                            
                            print("SPEEDVALUE \(self.Speed_One)")
                        }
                        else if(self.speedOne==0x30)
                        {
                            
                            self.Speed_Two = UInt16(UInt8((self.asciiToHex.index(of: self.speedTwo))!))
                            self.Speed_Three = UInt16(UInt8((self.asciiToHex.index(of: self.speedThree))!))
                            self.Speed_Four = UInt16(UInt8((self.asciiToHex.index(of: self.speedFour))!))
                            let speedValue = self.Speed_Two*100 + self.Speed_Three*10 + self.Speed_Four
                            self.txtSpeed.text=(String(speedValue))
                        }
                        else
                        {
                            self.Speed_One = UInt16(UInt8((self.asciiToHex.index(of: self.speedOne))!))
                            self.Speed_Two = UInt16(UInt8((self.asciiToHex.index(of: self.speedTwo))!))
                            self.Speed_Three = UInt16(UInt8((self.asciiToHex.index(of: self.speedThree))!))
                            self.Speed_Four = UInt16(UInt8((self.asciiToHex.index(of: self.speedFour))!))
                            
                            let speedValue = (UInt16(UInt(self.Speed_One*1000))) + self.Speed_Two*100 + self.Speed_Three*10 + self.Speed_Four
                            self.txtSpeed.text=(String(describing: speedValue))
                            
                        }
                    }
                }
        })*/
        
            
        let storyboard=UIStoryboard(name:"Main",bundle:nil)
        let connectView:ScannerViewController = storyboard.instantiateViewController(withIdentifier: "ScannerViewController") as! ScannerViewController
        
        connectView.transmitData(text: "")
      
       
    }
    
    
    @IBAction func onForwardBtn(_ sender: Any)
    {
    }
    
    
    @IBAction func onReverseBtn(_ sender: Any)
    {
    }
    
    func transit(text aText:String) -> String
    {
         ScannerViewController.sharedManager.transmitData(text: aText)
        return aText
    }
    
  func onButtonOneClick()
    
  {
    
   _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:  #selector(connectViewController.onButtonClick), userInfo: nil, repeats: true)
    }
    
    
    
    
    
    
func onButtonClick()
{
    
   
}

    @IBAction func sendValueBtn(_ sender: Any)
    {
       // connectViewController.globalVariable6.sendValueStorebool=[true]
 
  
        let storeSendSpeed = txtSpeed.text
        print("Speed value is \(storeSendSpeed)")
               
      
    
     //   ScannerViewController.globalVariable.speedValueStored = String(txtSpeed!.text!)!
            
        
      
        
       // let start = sendValueStore.s
        
         // set_SpeedFrame[0x4]=(asciiToHex[UInt8(FourDigit)])
        
    }
    
    @IBAction func onCancel(_ sender: Any)
    {
        
        
        self.dismiss(animated: true, completion: nil)

    }
    
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    
}
