//
//  MSUser.swift
//  MShare
//
//  Created by Lam Le on 6/21/16.
//  Copyright © 2016 Legiti Ltd. All rights reserved.
//

import UIKit

enum CloudType:String{
    case GOOGLEDRIVE = "GOOGLEDRIVE"
    case DROPBOX = "DROPBOX"
    case FACEBOOK = "FACEBOOK"
    case ONEDRIVE = "ONEDRIVE"
    case BOX = "BOX"
    case TWITTER = "TWITTER"
}
class MSUser: NSObject {
    var email:String?
    var name:String?
    
    var type:CloudType?;
    
//    func convertToDictionary()->[String:AnyObject]{
//        return [];
//    }
}

