//
//  ExampleController.swift
//  PageControllerExample
//
//  Created by 郑小燕 on 2018/4/2.
//  Copyright © 2018年 郑小燕. All rights reserved.
//

import UIKit

class ExampleController: UITableViewController {
    var dataArray = [("MenuViewStyleDefault", MenuViewStyle.default), ("MenuViewStyleLine", MenuViewStyle.line), ("MenuViewStyleFlood", MenuViewStyle.flood), ("MenuViewStyleFloodHollow", MenuViewStyle.floodHollow), ("MenuViewShowOnNav", MenuViewStyle.flood), ("MenuViewStyleSegmented", MenuViewStyle.segmented), ("MenuViewStyleTriangle", MenuViewStyle.triangle), ("MenuViewStyleNaughty", MenuViewStyle.line), ("MenuViewCornerRadius", MenuViewStyle.flood), ("MenuViewPositionBottom", MenuViewStyle.default)]
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
//        self.tableView.dataSource = self
//        self.tableView.delegate = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let (title, _) = dataArray[indexPath.row]
        cell.textLabel?.text  = title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (title, style) = dataArray[indexPath.row]
        let vc = CustomViewController()
        vc.selectIndex = 2
        vc.title = title
        vc.menuViewStyle = style
        vc.automaticallyCalculatesItemWidths = true
        if title == "MenuViewStyleNaughty" {
            vc.progressViewIsNaughty = true
            vc.progressWidth = 10
        } else if title == "MenuViewCornerRadius" {
            vc.progressViewCornerRadius = 5.0
        } else if title == "MenuViewPositionBottom" {
            vc.menuViewPosition = .bottom
        }
        switch style {
        case .default:
            vc.titleSizeSelected = 18
            break
        case .segmented:
            fallthrough
        case .flood:
            vc.titleColorSelected = UIColor.white
            vc.titleColorNormal = UIColor(red: 168.0/255.0, green: 20.0/255.0, blue: 4/255.0, alpha: 1)
            vc.progressColor = UIColor(red: 168.0/255.0, green: 20.0/255.0, blue: 4/255.0, alpha: 1)
            vc.showOnNavigationBar = true
            vc.menuViewLayoutMode = .center
            vc.titleSizeSelected = 18
            break
        case .triangle:
            vc.progressWidth = 6
            vc.progressHeight = 4
            vc.titleSizeSelected = 18
            vc.progressViewIsNaughty = false
        default:
            break
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override fun tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
