//
//  DropboxViewController.swift
//  MShare
//
//  Created by Lam Le on 6/7/16.
//  Copyright © 2016 Legiti Ltd. All rights reserved.
//

import UIKit
import Firebase
import Intercom
import FirebaseDatabaseUI
class DropboxViewController: CloudViewController,DBSessionDelegate,DBRestClientDelegate {
    var ref:FIRDatabaseReference!;
    var restClient:DBRestClient?;
    var cursor:String = String();
    var dataSource:[AnyObject] = [AnyObject]();
    override func viewDidLoad() {
        super.viewDidLoad()
        if(DBSession.sharedSession() == nil || DBSession.sharedSession().isLinked() == false){
            DBSession.sharedSession().linkFromController(self);
            DBSession.sharedSession().delegate = self;
        }
        else{
            restClient = DBRestClient.init(session: DBSession.sharedSession());
            restClient?.delegate = self;
            restClient?.loadMetadata("/");
            
            
            DBSession.sharedSession().addObserver(self, forKeyPath: "isLinked", options: [NSKeyValueObservingOptions.Initial,NSKeyValueObservingOptions.New], context: nil);
        }
//        
//        ref = FIRDatabase.database().reference().root;
//        print(ref.child("account").queryOrderedByKey().observeEventType(FIRDataEventType.Value, withBlock: { (snapShot) in
//            if(snapShot.childrenCount > 0){
//                
//            }
//        }))
////        ref.child("account1").setValue(["a":"bcd"])
////        let query:FIRDatabaseQuery = ref.queryOrderedByValue();
////        print(query);
//        let firebaseArray: FirebaseArray = FirebaseArray.init(ref: ref);
//        print(firebaseArray.count());

        // Do any additional setup after loading the view.
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if(keyPath == "isLinked"){
            print("Access");
            if(DBSession.sharedSession().isLinked()){
                print("Linked");
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func sessionDidReceiveAuthorizationFailure(session: DBSession!, userId: String!) {
        if(session != nil){
            self.restClient = DBRestClient.init(session: session, userId: userId);
            self.restClient?.delegate = self;
            restClient?.loadMetadata("/");
        }
    }

    /*
     * TABLE DATASOUR / DELEGATE
     */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier:String = "CelllIdentifier";
        
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath);
        
        if(cell == nil){
            cell = UITableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: "CelllIdentifier");
        }
        let source:DBMetadata = self.dataSource[indexPath.row] as! DBMetadata;
        cell?.textLabel?.text = source.filename;
        if(source.isDirectory){
            cell?.imageView?.image = UIImage.init(named: "icon_folder");
        }else{
            cell?.imageView?.image = nil;
        }
        
        return cell!;
    }
 
    /*
     * RESTCLIENT DELEGATE
    */
    func restClient(client: DBRestClient!, loadedDeltaEntries entries: [AnyObject]!, reset shouldReset: Bool, cursor: String!, hasMore: Bool) {
        self.cursor = cursor;
    }
    
    func restClient(client: DBRestClient!, loadedMetadata metadata: DBMetadata!) {
        self.dataSource.removeAll();
        if(metadata.contents.count > 0){
            for item in metadata.contents as! [DBMetadata] {
                if(item.isDirectory){
                    self.dataSource.append(item);
                }
                else if(item.filename.isVideoFile()){
                    self.dataSource.append(item);
                }
            }
        }
        
        self.tbView.reloadData();
        print(metadata.contents);
    }
    
    func restClient(client: DBRestClient!, loadMetadataFailedWithError error: NSError!) {
        print(error);
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item:DBMetadata = self.dataSource[indexPath.row] as! DBMetadata;
        self.restClient?.loadStreamableURLForFile(item.path);
        self.restClient?.loadSharableLinkForFile(item.path, shortUrl: true);
    }
    
    func restClient(restClient: DBRestClient!, loadSharableLinkFailedWithError error: NSError!) {
        print(error);
    }
    func restClient(restClient: DBRestClient!, loadedSharableLink link: String!, forFile path: String!) {
        print(link);
    }
    
    func restClient(restClient: DBRestClient!, loadedStreamableURL url: NSURL!, forFile path: String!) {
        print(url);
    }
    
    func restClient(restClient: DBRestClient!, loadStreamableURLFailedWithError error: NSError!) {
        print(error);
    }
}

