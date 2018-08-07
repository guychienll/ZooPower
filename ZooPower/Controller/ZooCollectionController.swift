//
//  ZooCollectionController.swift
//  ZooPower
//
//  Created by User8 on 2018/8/6.
//  Copyright © 2018年 com.fjuim. All rights reserved.
//

import UIKit

class ZooCollectionController: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource {
    
    
    // 標籤分頁頁碼
    var tab = 0
    // 海洋
    @IBAction func tab1(_ sender: Any) {
        tab = 0
    }
    // 草原
    @IBAction func tab2(_ sender: Any) {
        tab = 1
        
    }
    // 雨林
    @IBAction func tab3(_ sender: Any) {
        tab = 2
        
    }
    // 特區
    @IBAction func tab4(_ sender: Any) {
        tab = 3
    }
    
    // 動物資料
    var animalsImageName = ["藍鯨","小丑魚","狐獴縮圖","長頸鹿","渡渡鳥","樹蛙","獨角獸","鱷魚","藍鯨縮圖"]
    var animalsName = ["藍鯨","小丑魚","狐獴","長頸鹿","渡渡鳥","樹蛙","獨角獸","鱷魚","藍鯨"]
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return animalsName.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ZooCollectionCell
        
        
        switch tab {
        case 0:
            collectionView.backgroundColor = UIColor.init(red: 158/255, green: 186/255, blue: 232/255, alpha: 1)
            cell.animalImage.image = UIImage(named: animalsImageName[indexPath.row])
            cell.animalNameLabel.text = animalsName[indexPath.row]
            DispatchQueue.main.async{
                collectionView.reloadData()
            }
        case 1:
            collectionView.backgroundColor = UIColor.init(red: 155/255, green: 222/255, blue: 161/255, alpha: 1)
            cell.animalImage.image = UIImage(named: animalsImageName[indexPath.row])
            cell.animalNameLabel.text = animalsName[indexPath.row]
            DispatchQueue.main.async{
                collectionView.reloadData()
            }
        case 2:
            collectionView.backgroundColor =  UIColor.init(red: 245/255, green: 187/255, blue: 131/255, alpha: 1)
            cell.animalImage.image = UIImage(named: animalsImageName[indexPath.row])
            cell.animalNameLabel.text = animalsName[indexPath.row]
            DispatchQueue.main.async{
                collectionView.reloadData()
            }
        case 3:
            collectionView.backgroundColor =  UIColor.init(red: 201/255, green: 132/255, blue: 216/255, alpha: 1)
            cell.animalImage.image = UIImage(named: animalsImageName[indexPath.row])
            cell.animalNameLabel.text = animalsName[indexPath.row]
            DispatchQueue.main.async{
                collectionView.reloadData()
            }
        default:
            print("something wrong")
        }
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
