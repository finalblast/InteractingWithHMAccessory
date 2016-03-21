//
//  ViewController.swift
//  InteractingWithHMAccessory
//
//  Created by Nam (Nick) N. HUYNH on 3/21/16.
//  Copyright (c) 2016 Enclave. All rights reserved.
//

import UIKit
import HomeKit

extension HMCharacteristic {
    
    func containsProperty(paramProperty: String) -> Bool {
        
        if let properties = self.properties {
            
            for property in properties as [String] {
                
                if property == paramProperty {
                    
                    return true
                    
                }
                
            }
            
        }
        
        return false
        
    }
    
    func isReadable() -> Bool {
        
        return containsProperty(HMCharacteristicPropertyReadable)
        
    }
    
    func isWritable() -> Bool {
        
        return containsProperty(HMCharacteristicPropertyWritable)
    
    }
    
}

class ViewController: UIViewController {

    var home: HMHome!
    var room: HMRoom!
    var projectorAccessory: HMAccessory!
    
    var homeName: String = {
        
        let homeNameKey = "HomeName"
       let defaults = NSUserDefaults.standardUserDefaults()
        if let name = defaults.stringForKey(homeNameKey) {
            
            if countElements(name) > 0 {
                
                return name
                
            }
            
        }
        
        let newName = "Home \(arc4random_uniform(UInt32.max))"
        defaults.setValue(newName, forKey: homeNameKey)
        return newName
        
    }()
    
    lazy var accessoryBrowser: HMAccessoryBrowser = {
        
        let browser = HMAccessoryBrowser()
        browser.delegate = self
        return browser
        
    }()
    
    let roomName = "Bedroom"
    let accessoryName = "Cinema Room Projector"
    let switchServiceGroupName = "All Switches"
    
    var homeManager: HMHomeManager!
    var switchServiceGroup: HMServiceGroup?
    
    func createHome() {
        
        homeManager.addHomeWithName(homeName, completionHandler: { (home, error) -> Void in
            
            if error != nil {
                
                println("Failed to create home")
                
            } else {
                
                println("Successfully created home")
                self.home = home
                println("Creating room....")
                self.createRoom()
                
            }
            
        })
        
    }
    
    func createRoom() {
        
        home.addRoomWithName(roomName, completionHandler: { (room, error) -> Void in
            
            if error != nil {
                
                println("Failed to create room")
                
            } else {
                
                println("Successfully created room")
                self.room = room
                self.findOrCreateSwitchServiceGroup()
                
            }
            
        })
        
    }
    
    func findOrCreateSwitchServiceGroup() {
        
        if let groups = home.serviceGroups {
            
            for serviceGroup in groups as [HMServiceGroup] {
                
                if serviceGroup.name == switchServiceGroupName {
                    
                    switchServiceGroup = serviceGroup
                    
                }
                
            }
            
        }
        
        if switchServiceGroup == nil {
            
            println("Cannot find the switch service group. Creating it....")
            home.addServiceGroupWithName(switchServiceGroupName, completionHandler: { (group, error) -> Void in
                
                if error != nil {
                    
                    println("Failed to create the service group!")
                    
                } else {
                    
                    println("Create service successfully!")
                    self.switchServiceGroup = group
                    self.discoverServicesInServiceGroup(group)
                    
                }
                
            })
            
        } else {
            
            println("Found an existing switch service group!")
            discoverServicesInServiceGroup(switchServiceGroup)
            
        }
        
        println("Finding new accessories....")
        accessoryBrowser.startSearchingForNewAccessories()
        
    }
    
    func discoverServicesInServiceGroup(group: HMServiceGroup!) {
        
        addAllSwitchesToServiceGroup(group, completionHandler: { (error) -> Void in
            
            if error != nil {
                
                println("Failed to add the switch to the service group!")
                
            } else {
                
                self.enumerateServicesInServiceGroup(group)
                
            }
            
        })
        
        enumerateServicesInServiceGroup(group)
        
    }
    
    func enumerateServicesInServiceGroup(group: HMServiceGroup!) {
        
        println("Discovering all the services in this service group....")
        if let services = group.services {
            
            for service in services as [HMService] {
                
                println(service)
                
            }
            
        }
        
    }
    
    func addAllSwitchesToServiceGroup(group: HMServiceGroup!, completionHandler: (error: NSError!) -> Void) {
        
        if let accessories = room.accessories {
            
            for accessory in accessories as [HMAccessory] {
                
                if let services = accessory.services {
                    
                    for service in services as [HMService] {
                        
                        if (service.name as NSString).rangeOfString("switch", options: NSStringCompareOptions.CaseInsensitiveSearch).location != NSNotFound {
                            
                            println("Found a switch service, adding into group....")
                            group.addService(service, completionHandler: completionHandler)
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
//    func findCinemaRoomProjectorAccessory() {
//        
//        if let accessories = room.accessories {
//            
//            for accessory in accessories as [HMAccessory] {
//                
//                if accessory.name == accessoryName {
//                    
//                    println("Found the projector accessory in the room")
//                    self.projectorAccessory = accessory
//                    
//                }
//                
//            }
//            
//        }
//        
//        if self.projectorAccessory == nil {
//            
//            println("Could not find the projector accessory in the room")
//            println("Starting search for all available accessories")
//            accessoryBrowser.startSearchingForNewAccessories()
//            
//        } else {
//            
//            lowBrightnessOfProjector()
//            
//        }
//        
//    }
//    
//    func lowBrightnessOfProjector() {
//        
//        var brightnessOfProjectorCharacteristic: HMCharacteristic!
//        println("Finding the brightness characteristic of the project...")
//        for service in projectorAccessory.services as [HMService] {
//            
//            for characteristic in service.characteristics as [HMCharacteristic] {
//                
//                if characteristic.characteristicType == HMCharacteristicTypeBrightness {
//                    
//                    println("Found it!")
//                    brightnessOfProjectorCharacteristic = characteristic
//                    
//                }
//                
//            }
//            
//        }
//        
//        if brightnessOfProjectorCharacteristic == nil {
//            
//            println("Cannot find it!")
//            
//        } else {
//            
//            if brightnessOfProjectorCharacteristic.isReadable() == false {
//                
//                println("Cannot read the value of brightness characteristic!")
//                return
//                
//            }
//            
//            println("Reading the value of the brightness characteristic....")
//            brightnessOfProjectorCharacteristic.readValueWithCompletionHandler({ (error) -> Void in
//                
//                if error != nil {
//                    
//                    println("Cannot read the brightness value!")
//                    
//                } else {
//                    
//                    println("Read the brightness value. Setting it now....")
//                    if brightnessOfProjectorCharacteristic.isWritable() {
//                        
//                        let newValue = brightnessOfProjectorCharacteristic.value as Float - 1
//                        brightnessOfProjectorCharacteristic.writeValue(newValue, completionHandler: { (error) -> Void in
//                            
//                            if error != nil {
//                                
//                                println("Failed to setting the value of brightness!")
//                                
//                            } else {
//                                
//                                println("Successfully to setting the brightness value!")
//                                
//                            }
//                            
//                        })
//                        
//                    } else {
//                        
//                        println("Cannot write the brightness value!")
//                        
//                    }
//                    
//                }
//                
//            })
//         
//            if brightnessOfProjectorCharacteristic.value is Float {
//                
//                
//                
//            } else {
//                
//                println("The value of the brightness is not Float. Cannot set it!")
//                
//            }
//            
//        }
//        
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeManager = HMHomeManager()
        homeManager.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: HMHomeManagerDelegate, HMAccessoryBrowserDelegate {
    
    func homeManagerDidUpdateHomes(manager: HMHomeManager!) {
        
        for home in manager.homes as [HMHome] {
            
            if home.name == homeName {
                
                println("Found home")
                self.home = home
                
                for room in home.rooms as [HMRoom] {
                    
                    if room.name == roomName {
                        
                        println("Found room")
                        self.room = room
                        findOrCreateSwitchServiceGroup()
                        
                    }
                    
                }
                
                if self.room == nil {
                    
                    println("The room does not exist. Creating it....")
                    createRoom()
                    
                }
                
            }
            
        }
        
        if home == nil {
            
            println("The home does not exist. Creating it....")
            createHome()
            
        }
        
    }
    
    func accessoryBrowser(browser: HMAccessoryBrowser!, didFindNewAccessory accessory: HMAccessory!) {
        
        println("Found a new accessory...")
        if accessory.name == accessoryName {
            
            println("Discovered the projector accessory")
            println("Adding it to home....")
            home.addAccessory(accessory, completionHandler: { (error) -> Void in
                
                if error != nil {
                    
                    println("Failed to add it to the home")
                    
                } else {
                    
                    println("Successfully added to the home")
                    println("Assigning into room....")
                    self.home.assignAccessory(accessory, toRoom: self.room, completionHandler: { (error) -> Void in
                        
                        if error != nil {
                            
                            println("Failed to assign to room")
                            
                        } else {
                            
                            println("Successfully assigned to the room")
//                            self.findOrCreateSwitchServiceGroup()
//                            self.lowBrightnessOfProjector()
                            
                        }
                        
                    })
                    
                }
                
            })
            
        }
        
    }
    
}

