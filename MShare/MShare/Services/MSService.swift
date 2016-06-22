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
    static var sharedIntance:MSService = MSService();
    var startIndex:NSInteger = 0;
    var endIndex:NSInteger = 0;
    let ref:FIRDatabase = FIRDatabase.database();
    
    
    func addAccountToMS(user:MSUser){
//        let json = JSON(user);
//        ref.reference().child(kBranchOfUser).setValue([user.email : json]);
    }
    
    func checkAccountExist(user:MSUser, completion:(isExist:Bool)->Void){
        ref.reference().child(kBranchOfUser).queryOrderedByKey().observeEventType(FIRDataEventType.Value, withBlock: { (snapShot) in
            if(snapShot.childrenCount > 0){
                completion(isExist: true);
            }
            completion(isExist: false);
        })
    }
}
