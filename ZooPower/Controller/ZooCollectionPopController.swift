//
//  PopController.swift
//  ZooPower
//
//  Created by User8 on 2018/8/7.
//  Copyright © 2018年 com.fjuim. All rights reserved.
//

import UIKit

class ZooCollectionPopController: UIViewController {

    
    var animalsName : String?
    var animalsAreaName : String?
    
    @IBOutlet weak var animalsNameLabel: UILabel!{
        didSet{
            animalsNameLabel.text = animalsName
        }
    }
    @IBOutlet weak var animalsImageView: UIImageView!{
        didSet{
            animalsImageView.image = UIImage(named: animalsName!)
        }
    }
    @IBOutlet weak var animalsAreaLabel: UILabel!{
        didSet{
            animalsAreaLabel.text = animalsAreaName
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
