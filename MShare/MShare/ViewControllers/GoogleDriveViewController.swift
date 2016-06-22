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
            getFilesInGoogleDrive();
        } else {
            presentViewController(
                createAuthController(),
                animated: true,
                completion: nil
            )
        }
    }
    
    func getFilesInGoogleDrive(){
        let query:GTLQueryDrive = GTLQueryDrive.queryForFilesList();
        let parentId:String = "root";
        query.q = "'\(parentId)' in parents";
        
       
        
        service.executeQuery(query) { (ticket, object, error) in
            if(error == nil){
                let items:[GTLDriveFile] = (object as! GTLDriveFileList).files as! [GTLDriveFile];
                for item in items{
                    item.mimeType.isAudioFile()
                    self.dataSource.append(item);
                }
                
//                self.dataSource.sortInPlace({ (item1, item2) -> Bool in
//                    let item1:GTLDriveFile = item1 as! GTLDriveFile;
//                    let item2:GTLDriveFile = item2 as! GTLDriveFile;
//                    if(item1.f && item2.isDirectory){
//                        
//                        return item1.filename < item2.filename;
//                    }
//                    else{
//                        if(item1.isDirectory == true){
//                            return item1.isDirectory;
//                        }else if(item1.isDirectory == true){
//                            return item2.isDirectory;
//                        }
//                        return item1.filename < item2.filename;
//                    }
//
//                })
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
//            self.paths.append(item);
//            self.restClient?.loadMetadata(item.path);
//            self.updateHeader();
        }
    }
}
