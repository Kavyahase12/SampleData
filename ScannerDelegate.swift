//
//  ScannerDelegate.swift
//  EpochIphoneApp
//
//  Created by MAC Developers on 30/03/2017.
//  Copyright © 2017 MAC Developers. All rights reserved.
//

import Foundation
import CoreBluetooth

@objc protocol ScannerDelegate {
    func centralManagerDidSelectPeripheral(withManager aManager: CBCentralManager, andPeripheral aPeripheral: CBPeripheral)
}
