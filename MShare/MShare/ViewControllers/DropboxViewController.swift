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
import SwiftyJSON
class DropboxViewController: CloudViewController,DBSessionDelegate,DBRestClientDelegate {
    var ref:FIRDatabaseReference!;
    var restClient:DBRestClient?;
    var cursor:String = String();
    var dataSource:[AnyObject] = [AnyObject]();
    var paths:[DBMetadata] = [DBMetadata]();
    var scrollViewHeader:UIScrollView!;
    override func viewDidLoad() {
        super.viewDidLoad()
        if(DBSession.sharedSession() == nil || DBSession.sharedSession().isLinked() == false){
            DBSession.sharedSession().linkFromController(self);
            DBSession.sharedSession().delegate = self;
        }
        else{
            restClient = DBRestClient.init(session: DBSession.sharedSession());
            restClient?.delegate = self;
            paths.append(DBMetadata());
            restClient?.loadMetadata("/");
            
            
            DBSession.sharedSession().addObserver(self, forKeyPath: "isLinked", options: [NSKeyValueObservingOptions.Initial,NSKeyValueObservingOptions.New], context: nil);
        }
//        
        ref = FIRDatabase.database().reference().root;
        ref.child("account").queryOrderedByKey().observeEventType(FIRDataEventType.Value, withBlock: { (snapShot) in
            if(snapShot.childrenCount > 0){
                
            }
        })
////        ref.child("account1").setValue(["a":"bcd"])
////        let query:FIRDatabaseQuery = ref.queryOrderedByValue();
////        print(query);
//        let firebaseArray: FirebaseArray = FirebaseArray.init(ref: ref);
//        print(firebaseArray.count());

        // Do any additional setup after loading the view.
        let user:MSUser = MSUser();
        user.email = "a@yahoo.com";
        user.name = "quabebap";
        user.type = CloudType.BOX;
        
        
        do{
            let json:NSData = try NSJSONSerialization.dataWithJSONObject([user.email!,user.name!,user.type!.rawValue], options: NSJSONWritingOptions.PrettyPrinted);
            do{
                let decodedJson = try NSJSONSerialization.JSONObjectWithData(json, options: NSJSONReadingOptions.MutableContainers);
                ref.child("account1").setValue(["a@yahoo":decodedJson])
            }
            catch _{
                print("decode fail");
            }
        }
        catch _{
            print("Failure convert");
        }
       self.scrollViewHeader = UIScrollView.init(frame: CGRectMake(0, 0, self.tbView.frame.size.width, 30.0));
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
     * MARK: TABLE DATASOUR / DELEGATE
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
//            cell?.imageView?.image = UIImage.init(named: "icon_folder");
            cell?.backgroundColor = UIColor.grayColor();
        }else{
//            cell?.imageView?.image = nil;
            cell?.backgroundColor = UIColor.whiteColor();
        }
        
        return cell!;
    }
 
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0;
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        scrollViewHeader = UIScrollView.init(frame:CGRectMake(0, 0, tableView.frame.width, 30));
//        let headerView:UIView = UIView.init(frame:CGRectMake(0, 0, tableView.frame.width, 30));
//        
//        var width:CGFloat = 0.0;
//        for path in paths {
//            let button:UIButton = UIButton.init(frame: CGRectMake(0, width, 50, 30));
//            button.backgroundColor = UIColor.grayColor();
//            width += 50;
//            scrollViewHeader.addSubview(button);
//
//            if(paths.indexOf(path) == 0){
////                button.titleLabel?.text = "root";
//                button.setTitle("root", forState: .Normal);
//            }
//            else{
//                button.titleLabel?.text = path.path;
//                button.setTitle(path.path, forState: .Normal);
//            }
//            
//        }
//        scrollViewHeader.contentSize = CGSizeMake(width, 30);
//        headerView.addSubview(scrollViewHeader);
//        headerView.backgroundColor = UIColor.blueColor();
//        
//        scrollViewHeader.backgroundColor = UIColor.greenColor();
        return scrollViewHeader;
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item:DBMetadata = self.dataSource[indexPath.row] as! DBMetadata;
        
        if(item.isDirectory){
            self.paths.append(item);
            self.restClient?.loadMetadata(item.path);
            self.updateHeader();
        }
    }
    
    func updateHeader(){
        
        var width:CGFloat = 0.0;
        var index:NSInteger = 0;
        var button:UIButton;
        for subView  in scrollViewHeader.subviews {
            subView.hidden = true;
        }
        
        var sizeOfButton:CGSize;
        
        for path in paths {
            
            
            if(paths.indexOf(path) == 0){
                //                button.titleLabel?.text = "root";
                sizeOfButton = "root".sizeOfStringWithFont(UIFont.init(name: kFontHelveticaNeue, size: kSizeOfFontTitle)!, size: CGSizeMake(CGFloat.max, 30.0));
            }
            else{
                sizeOfButton = path.filename.sizeOfStringWithFont(UIFont.init(name: kFontHelveticaNeue, size: kSizeOfFontTitle)!, size: CGSizeMake(CGFloat.max, 30.0));
            }
            
            if(scrollViewHeader.viewWithTag(0) != nil && scrollViewHeader.viewWithTag(0)?.isKindOfClass(UIButton) == true){
                button = scrollViewHeader.viewWithTag(0) as! UIButton;
                
                if(paths.indexOf(path) == 0){
                    //                button.titleLabel?.text = "root";
                    button.setTitle("root", forState: .Normal);
                }
                else{
                    button.setTitle(path.filename, forState: .Normal);
                }
               
                button.frame = CGRectMake(width, 0, sizeOfButton.width, sizeOfButton.height);
            }
            else{
               
                
                button = UIButton.init(frame: CGRectMake(width, 0, sizeOfButton.width + 10, 30));
                
               
                scrollViewHeader.addSubview(button);
                
                if(paths.indexOf(path) == 0){
                    //                button.titleLabel?.text = "root";
                    button.setTitle("root", forState: .Normal);
                }
                else{
                    button.setTitle(path.filename, forState: .Normal);
                }
            }
            button.backgroundColor = UIColor.grayColor();
            button.titleLabel?.font = UIFont.init(name: kFontHelveticaNeue, size: kSizeOfFontTitle);
            button.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
            
            button.layer.cornerRadius = button.frame.height / 2.0;
            button.layer.masksToBounds = true;
            button.addTarget(self, action:#selector(DropboxViewController.loadDataFromPath(_:)), forControlEvents: UIControlEvents.TouchUpInside);
            button.tag = index;
            width = width + button.frame.size.width;
            index = index + 1;
            
            button.hidden = false;
        }
        scrollViewHeader.contentSize = CGSizeMake(width, 30);
        
        scrollViewHeader.scrollRectToVisible(CGRectMake(scrollViewHeader.contentSize.width - scrollViewHeader.frame.size.width, 0, scrollViewHeader.frame.size.width, scrollViewHeader.frame.size.height), animated: false);
        scrollViewHeader.setNeedsDisplay();
    }
    
    func loadDataFromPath(sender:UIButton){
        let index:NSInteger = sender.tag;
        
        self.paths.removeRange(index + 1..<self.paths.count);
        
        if(index == 0){
            restClient?.loadMetadata("/");
        }
        else{
            restClient?.loadMetadata(self.paths[index].path);
        }
        
    }
    /*
     *  MARK: RESTCLIENT DELEGATE
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
                else if(item.filename.isVideoFile() || item.filename.isAudioFile()){
                    self.dataSource.append(item);
                }
            }
            
            self.dataSource.sortInPlace({ (item1, item2) -> Bool in
                let item1:DBMetadata = item1 as! DBMetadata;
                let item2:DBMetadata = item2 as! DBMetadata;
                if(item1.isDirectory && item2.isDirectory){
                    
                    return item1.filename < item2.filename;
                }
                else{
                    if(item1.isDirectory == true){
                        return item1.isDirectory;
                    }else if(item1.isDirectory == true){
                        return item2.isDirectory;
                    }
                    return item1.filename < item2.filename;
                }
            })
        }
        
        self.tbView.reloadData();
        self.updateHeader();
        print(metadata.contents);
    }
    
    func restClient(client: DBRestClient!, loadMetadataFailedWithError error: NSError!) {
        print(error);
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

