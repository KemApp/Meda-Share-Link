//
//  GoogleDriveViewController.swift
//  MShare
//
//  Created by Lam Le on 6/22/16.
//  Copyright © 2016 Legiti Ltd. All rights reserved.
//

import UIKit
import GTMOAuth2
import GoogleAPIClient
class GoogleDriveViewController: CloudViewController {
    let scopes:[String] = [kGTLAuthScopeDrive];
    let service = GTLServiceDrive()
    var paths:[GTLDriveFile] = [GTLDriveFile]();
    var scrollViewHeader:UIScrollView!;
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(
            kGoogleDriveKeychainItemName,
            clientID: kGoogleClientID,
            clientSecret: nil) {
            service.authorizer = auth
        }

        // Do any additional setup after loading the view.
        self.scrollViewHeader = UIScrollView.init(frame: CGRectMake(0, 0, self.tbView.frame.size.width, 30.0));
        
        let root:GTLDriveFile = GTLDriveFile();
        root.identifier = "root";
        paths.append(root);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // When the view appears, ensure that the Drive API service is authorized
    // and perform API calls
    override func viewDidAppear(animated: Bool) {
        if let authorizer = service.authorizer,
            canAuth = authorizer.canAuthorize where canAuth {
            getFilesInGoogleDrive((paths.last?.identifier)!);
            
            let query:GTLQueryDrive = GTLQueryDrive.queryForAboutGet();
            query.fields = "user,storageQuota";
            
            service.executeQuery(query, completionHandler: { (ticket, object, error) in
                if(error == nil){
                    let about:GTLDriveAbout = object as! GTLDriveAbout;
                    let user:MSUser = MSUser();
                    user.email = about.user.emailAddress;
                    user.name = about.user.displayName;
                    user.type = CloudType.GOOGLEDRIVE;
                    MSService.sharedIntance.addAccountToMS(user, completion: { (isSucces) in
                        
                    });
                }
            })
            
        } else {
            presentViewController(
                createAuthController(),
                animated: true,
                completion: nil
            )
        }
    }
    
    func getFilesInGoogleDrive(parentId:String){
        self.dataSource.removeAll();
        let query:GTLQueryDrive = GTLQueryDrive.queryForFilesList();
        query.q = "'\(parentId)' in parents";
//        query.pageSize = 10;
       
        
        service.executeQuery(query) { (ticket, object, error) in
            if(error == nil){
                let items:[GTLDriveFile] = (object as! GTLDriveFileList).files as! [GTLDriveFile];
                for item in items{
                    if(item.isDirectory() || item.isAudioFile() || item.isVideoFile()){
                        self.dataSource.append(item);
                    }
                }
                
                self.dataSource.sortInPlace({ (item1, item2) -> Bool in
                    let item1:GTLDriveFile = item1 as! GTLDriveFile;
                    let item2:GTLDriveFile = item2 as! GTLDriveFile;
                    if(item1.isDirectory() && item2.isDirectory()){
                    
                        return item1.name < item2.name;
                    }
                    else{
                        if(item1.isDirectory() == true){
                            return item1.isDirectory();
                        }else if(item1.isDirectory() == true){
                            return item2.isDirectory();
                        }
                        return item1.name < item2.name;
                    }

                })
                self.tbView.reloadData();
                self.updateHeader();
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    /*
     * MARK: - GOOGLE AUTHENTICATE
    */
    // Creates the auth controller for authorizing access to Drive API
    private func createAuthController() -> GTMOAuth2ViewControllerTouch {
        let scopeString = scopes.joinWithSeparator(" ")
        return GTMOAuth2ViewControllerTouch(
            scope: scopeString,
            clientID: kGoogleClientID,
            clientSecret: nil,
            keychainItemName: kGoogleDriveKeychainItemName,
            delegate: self,
            finishedSelector: #selector(GoogleDriveViewController.viewController(_:finishedWithAuth:error:))
        )
    }
    
    // Handle completion of the authorization process, and update the Drive API
    // with the new credentials.
    func viewController(vc : UIViewController,finishedWithAuth authResult : GTMOAuth2Authentication, error : NSError?) {
        
        if let error = error {
            service.authorizer = nil
            showAlert("Authentication Error", message: error.localizedDescription)
            return
        }
        
        service.authorizer = authResult
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.Default,
            handler: nil
        )
        alert.addAction(ok)
        presentViewController(alert, animated: true, completion: nil)
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
        let source:GTLDriveFile = self.dataSource[indexPath.row] as! GTLDriveFile;
        cell?.textLabel?.text = source.name;
        
        if(source.isDirectory()){
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
        return scrollViewHeader;
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item:GTLDriveFile = self.dataSource[indexPath.row] as! GTLDriveFile;
        
        if(item.isDirectory()){
            self.paths.append(item);
            self.updateHeader();
            self.getFilesInGoogleDrive((self.paths.last?.identifier)!);
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
                sizeOfButton = path.name.sizeOfStringWithFont(UIFont.init(name: kFontHelveticaNeue, size: kSizeOfFontTitle)!, size: CGSizeMake(CGFloat.max, 30.0));
            }
            
            if(scrollViewHeader.viewWithTag(0) != nil && scrollViewHeader.viewWithTag(0)?.isKindOfClass(UIButton) == true){
                button = scrollViewHeader.viewWithTag(0) as! UIButton;
                
                if(paths.indexOf(path) == 0){
                    //                button.titleLabel?.text = "root";
                    button.setTitle("root", forState: .Normal);
                }
                else{
                    button.setTitle(path.name, forState: .Normal);
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
                    button.setTitle(path.name, forState: .Normal);
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
        self.getFilesInGoogleDrive((self.paths.last?.identifier)!);
//        self.updateHeader();
    }

    
}
