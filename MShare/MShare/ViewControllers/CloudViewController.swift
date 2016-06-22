//
//  CloudViewController.swift
//  MShare
//
//  Created by Lam Le on 6/7/16.
//  Copyright © 2016 Legiti Ltd. All rights reserved.
//

import UIKit

class CloudViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet var tbView:UITableView!;
    var dataSource:[AnyObject] = [AnyObject]();
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell.init();
    }
}
