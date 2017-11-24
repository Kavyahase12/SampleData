
//Received Frame transmission


import UIKit
import CoreBluetooth


fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

class ScannerViewController: UIViewController, CBCentralManagerDelegate,CBPeripheralDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let dfuServiceUUIDString  = "00001530-1212-EFDE-1523-785FEABCD123"
    let ANCSServiceUUIDString = "7905F431-B5CE-4E99-A40F-4B1E122D00D0"
    var state: CBCentralManagerState? {
        guard bluetoothManager != nil else {
            return nil
        }
        return CBCentralManagerState(rawValue: (bluetoothManager?.state.rawValue)!)
    }
    
//        //MARK: - ViewController Properties
    
    var bluetoothManager : CBCentralManager?
    var delegate         : ScannerDelegate?
    var filterUUID       : CBUUID?
    var peripherals      : [ScannedPeripheral]
    var timer            : Timer?
    var nameString :String?
    var receivedData0 = UInt8()
    var receivedData1 = UInt8()
    var receivedData2 = UInt8()
    var receivedData3 = UInt8()
    var receivedData4 = UInt8()
    var receivedData5 = UInt8()
var storeChracteriasticValue = UInt8()
    var  bluetoothPeripheral : CBPeripheral?
    //var logger   : NORLogger?
  
    
    var transbool=true
    //MARK: - Class Properties
    fileprivate let MTU = 20
    fileprivate let UARTServiceUUID             : CBUUID
  let UARTRXCharacteristicUUID    : CBUUID
    let UARTTXCharacteristicUUID    : CBUUID
    
    
    static  var uartRXCharacteristic        : CBCharacteristic?
    static var uartTXCharacteristic        : CBCharacteristic?
    
    fileprivate var connected = false
    
    @IBOutlet weak var devicesTable: UITableView!
    @IBOutlet weak var emptyView: UIView!
    //var speed = Double()
    var speed = Int()

    let asciiToHex=[0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x40,0x41,0x42,0x43]
    
    let motorStartArray : [UInt8] = [ 0x55, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
    let motorStopArray : [UInt8] = [ 0x55, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
   
    //bluetooth = CBCentralManager(delegate: self, queue: nil)
    

    
   @IBAction func cancelButtonTapped(_ sender: AnyObject)
    {
        self.dismiss(animated: true, completion: nil)
 }
    
    
    
    required init?(coder aDecoder: NSCoder)
    {
        peripherals = []
        UARTServiceUUID          = CBUUID(string: NORServiceIdentifiers.uartServiceUUIDString)
        UARTTXCharacteristicUUID = CBUUID(string: NORServiceIdentifiers.uartTXCharacteristicUUIDString)
        UARTRXCharacteristicUUID = CBUUID(string: NORServiceIdentifiers.uartRXCharacteristicUUIDString)
        super.init(coder: aDecoder)
    }
    init() {
        peripherals = []
        UARTServiceUUID          = CBUUID(string: NORServiceIdentifiers.uartServiceUUIDString)
        UARTTXCharacteristicUUID = CBUUID(string: NORServiceIdentifiers.uartTXCharacteristicUUIDString)
        UARTRXCharacteristicUUID = CBUUID(string: NORServiceIdentifiers.uartRXCharacteristicUUIDString)
        super.init(nibName: nil, bundle: nil)
        //Do whatever you want here
    }
    /*
     
     class var sharedManager: GlobalVariables {
     struct Static {
     static let instance = GlobalVariables()
     }
     return Static.instance
     }
     
     
     */
    class var sharedManager: ScannerViewController
    {
        struct globalVariable
        {
            // static  let array:[Int]=[]
            static var speedValueStored = String()
            static var digits = [String]()
            static let instance = ScannerViewController()
        

        }
 return globalVariable.instance
    }
    
    //MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        devicesTable.delegate = self
        devicesTable.dataSource = self
        
        let activityIndicatorView  = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicatorView.hidesWhenStopped = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)
        
        activityIndicatorView.startAnimating()
      //  print("VALUEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE \(ScannerViewController.globalVariable.rcvData0)")
  
        let centralQueue = DispatchQueue(label: "no.nordicsemi.nRFToolBox", attributes: [])
        bluetoothManager = CBCentralManager(delegate: self, queue: centralQueue)
        
        devicesTable.register(UINib(nibName: "scannerTableViewCell", bundle: nil), forCellReuseIdentifier: "scannerTableViewCell")
        
    }
    
       
    //MARK: - CBCentralManagerDelga te
    /**
     * Connects to the given peripheral.
     *
     * - parameter aPeripheral: target peripheral to connect to
     */
    
    func getConnectedPeripherals() -> [CBPeripheral] {
        guard let bluetoothManager = bluetoothManager else {
            return []
        }
        
        var retreivedPeripherals : [CBPeripheral]
        
        if filterUUID == nil {
            let dfuServiceUUID       = CBUUID(string: dfuServiceUUIDString)
            let ancsServiceUUID      = CBUUID(string: ANCSServiceUUIDString)
            retreivedPeripherals     = bluetoothManager.retrieveConnectedPeripherals(withServices: [dfuServiceUUID, ancsServiceUUID])
        } else
        {
            retreivedPeripherals     = bluetoothManager.retrieveConnectedPeripherals(withServices: [filterUUID!])
        }
    
        print("Retrived peripheral is \(retreivedPeripherals)")
        return retreivedPeripherals
    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else {
            print("Bluetooth is porewed off")
            return
        }
        
        let connectedPeripherals = self.getConnectedPeripherals()
        var newScannedPeripherals: [ScannedPeripheral] = []
        connectedPeripherals.forEach { (connectedPeripheral: CBPeripheral) in
            let connected = connectedPeripheral.state == .connected
            let scannedPeripheral = ScannedPeripheral(withPeripheral: connectedPeripheral, andIsConnected: connected )
            newScannedPeripherals.append(scannedPeripheral)
        }
        peripherals = newScannedPeripherals
        let success = self.scanForPeripherals(true)
        if !success {
            print("Bluetooth is powered off!")
        }
    }
    
    
    
    /**
     * Starts scanning for peripherals with rscServiceUUID.
     * - parameter enable: If YES, this method will enable scanning for bridge devices, if NO it will stop scanning
     * - returns: true if success, false if Bluetooth Manager is not in CBCentralManagerStatePoweredOn state.
     */
    
    
    
    func scanForPeripherals(_ enable:Bool) -> Bool {
        // print("in Scan")
        guard bluetoothManager?.state == .poweredOn else {
            // print("in Scan")
            return false
        }
        
        DispatchQueue.main.async
            {
                if enable == true
                {
                    //  print("in Scan1")
                    
                    let options: NSDictionary = NSDictionary(objects: [NSNumber(value: true as Bool)], forKeys: [CBCentralManagerScanOptionAllowDuplicatesKey as NSCopying])
                    if self.filterUUID != nil {
                        self.bluetoothManager?.scanForPeripherals(withServices: [self.filterUUID!], options: options as? [String : AnyObject])
                    } else {
                        self.bluetoothManager?.scanForPeripherals(withServices: nil, options: options as? [String : AnyObject])
                    }
                    
                }
                else
                    
                {
                    self.timer?.invalidate()
                    self.timer = nil
                    self.bluetoothManager?.stopScan()
                }
        }
        
        return true
    }
    
    
    
    @objc func timerFire()
    {
        if peripherals.count > 0
        {
            emptyView.isHidden = true
            devicesTable.reloadData()
        }
    }
    
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    {
        //  print("in Scan2")
        // Scanner uses other queue to send events. We must edit UI in the main queue
        print("Discovered peripheral name is \(peripheral.name)")
        print("Discovered peripheral identifier is \(peripheral.identifier.uuidString)")
        
        print("RSSI VALUE IS \(RSSI)")
        
  
         _ = peripheral.identifier
     //var dataArray =
      //  dataLength.copyBytes(to: &dataArray, count: dataLength * MemoryLayout<UInt8>.size)
      //  dataLength
        // for (item) in dataArray
        // {
        // print("DATA ARRAYYYYYYYYYYYYY \(dataArray)")
        // }

// */
        
        DispatchQueue.main.async(execute:
            {
                var sensor = ScannedPeripheral(withPeripheral: peripheral, andRSSI: RSSI.int32Value, andIsConnected: false)
                
                if ((self.peripherals.contains(sensor)) == false)
                {
                    self.peripherals.append(sensor)
                }
                else
                {
                    sensor = self.peripherals[self.peripherals.index(of: sensor)!]
                    sensor.RSSI = RSSI.int32Value
                    
                    self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerFire), userInfo: nil, repeats: true)
                }
        })
        
        
        //   bluetoothManager?.connect(peripheral, options: nil)
      //  bluetoothManager?.stopScan()
        
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
    {
        //  print("in Scan3")
        print("Did connect peripheral %@\( peripheral)");
        //  print("Bluetooth Manager --> didConnectPeripheral")
        // connected = true
        
               
        bluetoothPeripheral = peripheral
        bluetoothPeripheral!.delegate = self
        
        // delegate?.didConnectPeripheral(deviceName: peripheral.name)
        peripheral.discoverServices([UARTServiceUUID])
        bluetoothManager?.stopScan()
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?)
    {
        bluetoothManager?.stopScan()

        guard error == nil else
        {
            
            print("Service discovery failed")
            
            return
        }
        
        for aService: CBService in peripheral.services!
        {
            if aService.uuid.isEqual(UARTServiceUUID)
            {
                print("Found correct service")
                
                // bluetoothPeripheral!.discoverCharacteristics([UARTServiceUUID], for: aService)
                
                bluetoothPeripheral!.discoverCharacteristics([UARTTXCharacteristicUUID,UARTRXCharacteristicUUID], for: aService)
                
                return
            }
        }
        
    }
    
func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?)
    {
        
        guard error == nil else
        {
            print("Characteristics discovery failed..")
            
            return
            
        }
        print("Characteristics discovered")
        
        
        if service.uuid.isEqual(UARTServiceUUID)
        {
            for aCharacteristic : CBCharacteristic in service.characteristics!
            {
                
                
                if aCharacteristic.uuid.isEqual(UARTRXCharacteristicUUID)
                {
                    print("RX Characteristic found...")
                 ScannerViewController.uartRXCharacteristic = aCharacteristic
                   
                    bluetoothPeripheral!.setNotifyValue(true, for:    ScannerViewController.uartRXCharacteristic!)
                    }
                

                
               
                else if aCharacteristic.uuid.isEqual(UARTTXCharacteristicUUID)
                {
                    
                    print("TX Characteristic found...")
                    ScannerViewController.uartTXCharacteristic = aCharacteristic
                    
                    
                    bluetoothPeripheral!.setNotifyValue(true, for: ScannerViewController.uartTXCharacteristic!)
                               }
            }
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?)
    {
        guard error == nil else
        {
            print("WRITING VALUE TO CHARACTERISTIC HAS BEEN FAILED")
          
            return
        }
        
       print( "DATA WRITTEN TO BE CHARACTERISTIC: \(characteristic.uuid.uuidString)")
    }
    
    
 
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else
        {
            print( "Enabling notifications failed")
                                  return
        }
        
        if characteristic.isNotifying
        {
            print( "Notifications enabled for characteristic: \(characteristic.uuid.uuidString)")
        } else
        {
            print( "Notifications disabled for characteristic: \(characteristic.uuid.uuidString)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)
    {
        guard error == nil else
        {
            print( "Updating characteristic has failed")
            return
        }
       
        print("Received data on a characteristic.")
        // try to print a friendly string of received bytes if they can be parsed as UTF8
        
        print("Received Data Value is \(characteristic.value!)")
        
        guard let bytesReceived = characteristic.value else
        {
            print("Notification received from: \(characteristic.uuid.uuidString), with empty value")
            print( "Empty packet received")
            return
        }
        
        bytesReceived.withUnsafeBytes
            {
                (utf8Bytes: UnsafePointer<CChar>) in
                var len = bytesReceived.count // count-calculate the number of byte in data
                if utf8Bytes[len - 1] == 0
                {
                    len -= 1 // if the string is null terminated, don't pass null terminator into NSMutableString constructor
                 }
                
                
                print("BYTE RECEIVED VALUE IS \(bytesReceived.hexString)")
                
                let array = UnsafeMutablePointer<UInt8>(mutating: (bytesReceived as NSData).bytes.bindMemory(to: UInt8.self, capacity: bytesReceived.count))
                
                receivedData0 = (UInt8(Int(UInt16(array[0]))))
                print("Data 0 \(array[0])")
                
                receivedData1 = (UInt8(Int(UInt16(array[1]))))
                print("Data 1 \(array[1])")
                
                receivedData2 = (UInt8(UInt16(array[2])))
                    receivedData3 = (UInt8(UInt16(array[3])))
                
                receivedData4 = (UInt8(UInt16(array[4])))
                
                receivedData5 = (UInt8(UInt16(array[5])))
                
                connectViewController.globalVariable6.getSpeedZero=receivedData0
                connectViewController.globalVariable6.getSpeedOne=receivedData1
                connectViewController.globalVariable6.getSpeedTwo=receivedData2
                connectViewController.globalVariable6.getSpeedThree=receivedData3
                connectViewController.globalVariable6.getSpeedFour=receivedData4
                connectViewController.globalVariable6.getSpeedFive=receivedData5

                
                
        }
        //Write Value on Characteristic
        //Transmission Function
       
        //transmitData(text: "")
    }
    
 
    
    
    func transmitData(text aText:String) -> String
    {
        
    
        for i in 1...40
        {
            
            //pass dec value
            
            // speedMotor = [speed7 as! NSData]
            
            let enablyBytes = NSData(bytes:motorStartArray, length:motorStartArray.count)
            print("ENABLE Bytes \(enablyBytes)")
            
            
            
            
            // let enablyBytes = UnsafeMutablePointer<UInt16>(mutating: (enableValue as NSData).bytes.bindMemory(to: UInt16.self, capacity: enableValue))
            // if characteristic.uuid.isEqual(UARTRXCharacteristicUUID)
            
            // {
            //   print("RX Characteristic found...")
            //  uartRXCharacteristic = characteristic
            //}
            
         

            if (ScannerViewController.uartRXCharacteristic==nil)
            {
             print("Noooooo")
            }
            else
            {
                
                 bluetoothPeripheral?.writeValue(enablyBytes as Data, for: ScannerViewController.uartRXCharacteristic!, type:CBCharacteristicWriteType.withResponse)
                print("ENABLE Bytes1211221 \(enablyBytes)")
                
               // self.bluetoothPeripheral?.readValue(for: ScannerViewController.uartRXCharacteristic!)
                self.bluetoothPeripheral?.readValue(for: ScannerViewController.uartTXCharacteristic!)
                
           
            }
        }
        

      
        return aText
    }
    
    
    
    func stopMotor (text aText:String) -> String
    {
        print("UR IN TRANSMIT")
        
        
        
        for i in 1...40
        {
            
            //pass dec value
            
            // speedMotor = [speed7 as! NSData]
            
            let enablyBytes = NSData(bytes:motorStopArray, length:motorStopArray.count)
            print("ENABLE Bytes \(enablyBytes)")
            
            
            
            
            // let enablyBytes = UnsafeMutablePointer<UInt16>(mutating: (enableValue as NSData).bytes.bindMemory(to: UInt16.self, capacity: enableValue))
            // if characteristic.uuid.isEqual(UARTRXCharacteristicUUID)
            
            // {
            //   print("RX Characteristic found...")
            //  uartRXCharacteristic = characteristic
            //}
            
            bluetoothPeripheral?.setNotifyValue(true, for: ScannerViewController.uartRXCharacteristic!)
            
            bluetoothPeripheral?.writeValue(enablyBytes as Data, for: ScannerViewController.uartRXCharacteristic!, type:CBCharacteristicWriteType.withResponse)
            
            bluetoothPeripheral?.readValue(for: ScannerViewController.uartRXCharacteristic!)
        }
        
        
        
        return aText
    }
    
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        // 1
        if characteristic.isNotifying {
            // notification started
            print("Notification STARTED on characteristic: \(characteristic)")
        } else {
            // 2
            print("Notification STOPPED on characteristic: \(characteristic)")
            bluetoothManager?.cancelPeripheralConnection(peripheral)
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        bluetoothManager?.stopScan()
        
        // Call delegate method
        
        let peripheral = peripherals[indexPath.row].peripheral
        print("PERIPHERAL is \(peripheral) ")
        //self.delegate?.centralManagerDidSelectPeripheral(withManager: bluetoothManager!, andPeripheral: peripheral)
        //  connectPeripheral(peripheral: peripheral)
        bluetoothManager?.connect(peripheral, options:nil)
         let storyboard=UIStoryboard(name:"Main",bundle:nil)
        let scannerViewController = storyboard.instantiateViewController(withIdentifier: "connectViewController")
        self.present(scannerViewController, animated: true, completion: nil)
       
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return peripherals.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
       // let aCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        //Update cell content
        
        let aCell = tableView.dequeueReusableCell(withIdentifier: "scannerTableViewCell", for: indexPath) as! scannerTableViewCell
        let scannedPeripheral = peripherals[indexPath.row]
        aCell.nameLabel?.text = scannedPeripheral.name()
    
      // aCell.detailTextLabel?.text=String(describing: scannedPeripheral.peripheral.identifier)
        aCell.IdnLabel?.text=String(describing: scannedPeripheral.peripheral.identifier.debugDescription)
      
        if scannedPeripheral.isConnected == true
        {
            aCell.imageRSSI!.image = UIImage(named: "Connected")
        } else {
            let RSSIImage = self.getRSSIImage(RSSI: scannedPeripheral.RSSI)
            aCell.imageRSSI!.image = RSSIImage
        }
        
        return aCell
    }
    
    
    func getRSSIImage(RSSI anRSSIValue: Int32) -> UIImage
    {
        var image: UIImage
        
        if (anRSSIValue < -90) {
            image = UIImage(named: "Signal_0")!
        } else if (anRSSIValue < -70) {
            image = UIImage(named: "Signal_1")!
        } else if (anRSSIValue < -50) {
            image = UIImage(named: "Signal_2")!
        } else {
            image = UIImage(named: "Signal_3")!
        }
        
        return image
    }
    
}

