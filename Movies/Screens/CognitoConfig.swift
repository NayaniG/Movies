//
//  CognitoConfig.swift
//  Movies
//
//  Created by SJI-GOA-79 on 20/12/22.
//

import Foundation
import AWSCore

class CognitoConfig: NSObject {
    
    var keys:Dictionary<String,Any>?
    
    override init() {
        super.init()
        self.keys = readPropertyList()

    }
    
    func readPropertyList() -> Dictionary<String,Any>? {
        if let path = Bundle.main.path(forResource: "CognitoConfig", ofType: "plist") {
            let keys = NSDictionary(contentsOfFile: path)
            return keys as? Dictionary<String,Any>
        }
        return nil
    }
    
    func getPoolId() -> String {
        let poolId = self.keys?["poolId"] as? String
        guard poolId != nil else {
            fatalError("You must specify a poolId in your CognitoConfig.plist file")
        }
        return poolId!
    }
    
    func getClientId() -> String {
        let clientId = self.keys?["clientId"] as? String
        guard clientId != nil else {
            fatalError("You must specify a clientlId in your CognitoConfig.plist file")
        }
        return clientId!
    }
    
    func getClientSecret() -> String {
        let clientSecret = self.keys?["clientSecret"] as? String
        guard clientSecret != nil else {
            fatalError("You must specify a clientSecret in your CognitoConfig.plist file")
        }
        return clientSecret!
    }
    
    func getRegion() -> AWSRegionType {
        let region = self.keys?["region"] as? String
        guard region != nil else {
            fatalError("You must specify a region value in CognitoConfig.plist")
        }
        var output:AWSRegionType?
        
        switch region! {
            
        case "us-east-1":
            output = AWSRegionType.USEast1
        case "us-east-2":
            output = AWSRegionType.USEast2
        case "us-west-1":
            output = AWSRegionType.USWest1
        case "us-west-2":
            output = AWSRegionType.USWest2
        case "ap-south-1":
            output = AWSRegionType.APSouth1
        case "ap-northeast-1":
            output = AWSRegionType.APNortheast1
        case "ap-northeast-2":
            output = AWSRegionType.APNortheast2
        case "ap-southeast-1":
            output = AWSRegionType.APSoutheast1
        case "ap-southeast-2":
            output = AWSRegionType.APSoutheast2
        case "ca-central-1":
            output = AWSRegionType.CACentral1
        case "cn-north-1":
            output = AWSRegionType.CNNorth1
        case "eu-central-1":
            output = AWSRegionType.EUCentral1
        case "eu-west-1":
            output = AWSRegionType.EUWest1
        case "eu-west-2":
            output = AWSRegionType.EUWest2
        case "sa-east-1":
            output = AWSRegionType.SAEast1
        case "us-gov-west-1":
            output = AWSRegionType.USGovWest1
        default:
            print("Invalid region specified")
            
        }
        
        guard output != nil else {
            fatalError("You must specify a valid region value in CognitoConfig.plist such as 'us-east-1'")
        }
        
        return output!
    }
    
}
