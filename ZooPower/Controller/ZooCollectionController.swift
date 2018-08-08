//
//  ZooCollectionController.swift
//  ZooPower
//
//  Created by User8 on 2018/8/6.
//  Copyright © 2018年 com.fjuim. All rights reserved.
//

import UIKit

class ZooCollectionController: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource {
    
    
    @IBOutlet weak var zooCollectionView: UICollectionView!
    
    // 標籤分頁頁碼
    var tab = 0
    // 海洋
    @IBAction func tab1(_ sender: Any) {
        tab = 0
        self.zooCollectionView.reloadData()
    }
    // 草原
    @IBAction func tab2(_ sender: Any) {
        tab = 1
        self.zooCollectionView.reloadData()

    }
    // 雨林
    @IBAction func tab3(_ sender: Any) {
        tab = 2
        self.zooCollectionView.reloadData()

    }
    // 特區
    @IBAction func tab4(_ sender: Any) {
        tab = 3
        self.zooCollectionView.reloadData()
    }
    
    //動物圖片名稱
    var animalsImageName_Ocean = ["藍鯨縮圖","小丑魚縮圖","","","","","","",""]
    var animalsImageName_GrassLand = ["狐獴縮圖","長頸鹿縮圖","","","","","","",""]
    var animalsImageName_RainForest = ["樹蛙縮圖","鱷魚縮圖","","","","","","",""]
    var animalsImageName_Special = ["獨角獸縮圖","渡渡鳥縮圖","","","","","","",""]
    //動物名稱
    var animalsName_Ocean = ["藍鯨","小丑魚","","","","","","",""]
    var animalsName_GrassLand = ["狐獴","長頸鹿","","","","","","",""]
    var animalsName_RainForest = ["樹蛙","鱷魚","","","","","","",""]
    var animalsName_Special = ["獨角獸","渡渡鳥","","","","","","",""]
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ZooCollectionCell
        
        
        switch tab {
        case 0:
            collectionView.backgroundColor = UIColor.init(red: 158/255, green: 186/255, blue: 232/255, alpha: 1)
            cell.animalImage.image = UIImage(named: animalsImageName_Ocean[indexPath.row])
            cell.animalNameLabel.text = animalsName_Ocean[indexPath.row]
        case 1:
            collectionView.backgroundColor = UIColor.init(red: 155/255, green: 222/255, blue: 161/255, alpha: 1)
            cell.animalImage.image = UIImage(named: animalsImageName_GrassLand[indexPath.row])
            cell.animalNameLabel.text = animalsName_GrassLand[indexPath.row]
        case 2:
            collectionView.backgroundColor =  UIColor.init(red: 245/255, green: 187/255, blue: 131/255, alpha: 1)
            cell.animalImage.image = UIImage(named: animalsImageName_RainForest[indexPath.row])
            cell.animalNameLabel.text = animalsName_RainForest[indexPath.row]
        case 3:
            collectionView.backgroundColor =  UIColor.init(red: 201/255, green: 132/255, blue: 216/255, alpha: 1)
            cell.animalImage.image = UIImage(named: animalsImageName_Special[indexPath.row])
            cell.animalNameLabel.text = animalsName_Special[indexPath.row]
        default:
            print("something wrong")
        }
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
