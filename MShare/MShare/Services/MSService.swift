//
//  MSService.swift
//  MShare
//
//  Created by Lam Le on 6/21/16.
//  Copyright © 2016 Legiti Ltd. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON
class MSService: NSObject {
    let sharedIntance:MSService = MSService();
    var startIndex:NSInteger = 0;
    var endIndex:NSInteger = 0;
    let ref:FIRDatabase = FIRDatabase.database();
    
    
    func addAccountToMS(user:MSUser){
//        let json = JSON(user);
//        ref.reference().child(kBranchOfUser).setValue([user.email : json]);
    }
}
