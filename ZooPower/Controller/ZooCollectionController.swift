//
//  ZooCollectionController.swift
//  ZooPower
//
//  Created by User8 on 2018/8/6.
//  Copyright © 2018年 com.fjuim. All rights reserved.
//

import UIKit
import Firebase

class ZooCollectionController: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource {
    
    var ref : DatabaseReference?
    var currentID = Auth.auth().currentUser?.uid
    var accumulatedDistance = 0.0
    var oceanAccumulatedDistance = 0.0
    var grassLandAccumulatedDistance = 0.0
    var rainForestAccumulatedDistance = 0.0
    @IBOutlet weak var zooCollectionView: UICollectionView!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    let animalsImageName_All = [
        ["藍鯨","小丑魚","藍點魟","海星","豆腐鯊","水母","海龜","寄居蟹","北極熊","ocean"] ,
        ["斑馬","獅子","瞪羚","犀牛","非洲象","紅鶴","河馬","狐獴","長頸鹿","grassland"] ,
        ["鱷魚","巨嘴鳥","紅毛猩猩","美洲豹","蜂鳥","樹蛙","蟒蛇","鸚鵡","變色龍","rainforest"] ,
        ["獨角獸","渡渡鳥","special","special","special","special","special","special","special","special"]
    ]
    
    let animalsIntro = [ ["藍鯨","小丑魚","藍點魟","海星","豆腐鯊","水母","海龜","寄居蟹","北極熊"] ,
                         ["斑馬","獅子","瞪羚","犀牛","非洲象","紅鶴","河馬","狐獴","長頸鹿"] ,
                         ["鱷魚","巨嘴鳥","紅毛猩猩","美洲豹","蜂鳥","樹蛙","蟒蛇","鸚鵡","變色龍"] ,
                         ["獨角獸","渡渡鳥","special","special","special","special","special","special","special"]]
    
    let animalsAreaName = ["海洋地區","草原地區","雨林地區","特別地區"]
    var animalsImageName_displayed = [String]()
    var cnt = 0
    var oceanCount = 0
    var grassLandCount = 0
    var rainForestCount = 0
    // 標籤分頁頁碼
    var tab = 0
    // 海洋
    @IBAction func tab1(_ sender: Any) {
        tab = 0
        self.oceanCount = 0
        loadData()
    }
    // 草原
    @IBAction func tab2(_ sender: Any) {
        tab = 1
        self.grassLandCount = 0
        loadData()
    }
    // 雨林
    @IBAction func tab3(_ sender: Any) {
        tab = 2
        self.rainForestCount = 0
        loadData()
    }
    // 特區
    @IBAction func tab4(_ sender: Any) {
        tab = 3
        self.cnt = 0
        loadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ZooCollectionCell
        
        if animalsImageName_displayed.count == 9 {
        cell.animalImage.image = UIImage(named: animalsImageName_displayed[indexPath.row])
        }
        switch tab {
        case 0:
           backgroundImage.image = UIImage(named: "圖鑒模板海洋")
        case 1:
         backgroundImage.image = UIImage(named: "圖鑒模板草原")
        case 2:
           backgroundImage.image = UIImage(named: "圖鑒模板雨林")
        case 3:
            backgroundImage.image = UIImage(named: "圖鑒模板特區")
        default:
            print("something wrong")
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ZooCollectionPopController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ZooCollectionPopController") as? ZooCollectionPopController
        ZooCollectionPopController?.animalsName = animalsImageName_displayed[indexPath.row]
        ZooCollectionPopController?.animalsIntro = animalsIntro[tab][indexPath.row]
        switch tab {
        case 0:
            ZooCollectionPopController?.animalsAreaName = animalsAreaName[0]
        case 1:
            ZooCollectionPopController?.animalsAreaName = animalsAreaName[1]
        case 2:
            ZooCollectionPopController?.animalsAreaName = animalsAreaName[2]
        case 3:
            ZooCollectionPopController?.animalsAreaName = animalsAreaName[3]
        default:
            print("something wrong")
        }
        present(ZooCollectionPopController!, animated: true, completion: nil)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    ref = Database.database().reference()
        loadData()
      
    }
    private func loadData(){
       
        
        ref?.child("Records/\(currentID!)").observe(.childAdded, with: { (snapshot) in
            let values = snapshot.value as! [String : AnyObject]
            
            //各區累積里程數轉單位為公里（海洋、草原、雨林、全區）
            let oceanDistanceToKilometers = (values["oceanDistance"] as! Double) / 1000
            let grassLandDistanceToKilometers = (values["grassLandDistance"] as! Double) / 1000
            let rainForestDistanceToKilometers = (values["rainForestDistance"] as! Double) / 1000
            let distanceToKilometers = (values["distance"] as! Double) / 1000
            
            //各區累積里程數歸零（海洋、草原、雨林、全區）
            self.accumulatedDistance = 0.0
            self.oceanAccumulatedDistance = 0.0
            self.grassLandAccumulatedDistance = 0.0
            self.rainForestAccumulatedDistance = 0.0
            //各區里程數累積（海洋、草原、雨林、全區）
            self.oceanAccumulatedDistance += oceanDistanceToKilometers
            self.grassLandAccumulatedDistance += grassLandDistanceToKilometers
            self.rainForestAccumulatedDistance += rainForestDistanceToKilometers
            self.accumulatedDistance += distanceToKilometers
            //各區動物數（海洋、草原、雨林、全區）
            self.oceanCount = self.oceanCount + (Int(self.oceanAccumulatedDistance) / 5)
            self.grassLandCount = self.grassLandCount + (Int(self.grassLandAccumulatedDistance) / 5)
            self.rainForestCount = self.rainForestCount + (Int(self.rainForestAccumulatedDistance) / 5)
            self.cnt = self.cnt + (Int(self.accumulatedDistance) / 5)
            
            self.animalsImageName_displayed = []
            
            switch self.tab {
            case 0 :
                for i in 0...8{
                    
                    if i < self.oceanCount {
                        self.animalsImageName_displayed.append(self.animalsImageName_All[0][i])
                    }
                    else{
                        self.animalsImageName_displayed.append(self.animalsImageName_All[0][9])
                    }
                    
                }
            case 1 :
                for i in 0...8{
                    
                    if i < self.grassLandCount {
                        self.animalsImageName_displayed.append(self.animalsImageName_All[1][i])
                    }
                    else{
                        self.animalsImageName_displayed.append(self.animalsImageName_All[1][9])
                    }
                    
                }
            case 2 :
                for i in 0...8{
                    
                    if i < self.rainForestCount {
                        self.animalsImageName_displayed.append(self.animalsImageName_All[2][i])
                    }
                    else{
                        self.animalsImageName_displayed.append(self.animalsImageName_All[2][9])
                    }
                    
                }
            case 3 :
                for i in 0...8{
                    
                    if i < self.cnt {
                        self.animalsImageName_displayed.append(self.animalsImageName_All[3][i])
                    }
                    else{
                        self.animalsImageName_displayed.append(self.animalsImageName_All[3][9])
                    }
                    
                }
            default:
                print("default ")
            }
            
            self.zooCollectionView.reloadData()
        })
        
    }
    
}
