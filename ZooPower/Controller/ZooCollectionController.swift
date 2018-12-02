//
//  ZooCollectionController.swift
//  ZooPower
//
//  Created by User8 on 2018/8/6.
//  Copyright © 2018年 com.fjuim. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
class ZooCollectionController: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource {
    var animalsNameArray = [[],[],[],[]]
    var animalsIntroArray = [[],[],[],[]]
    var ref : DatabaseReference?
    var currentID = Auth.auth().currentUser?.uid
    let storageRef = Storage.storage().reference()
    var accumulatedDistance = 0.0
    var oceanAccumulatedDistance = 0.0
    var grassLandAccumulatedDistance = 0.0
    var rainForestAccumulatedDistance = 0.0
    let animalsAreaName = ["海洋區","草原區","雨林區","特區"]
    let animalsAreaBackgroundName = ["圖鑒模板海洋","圖鑒模板草原","圖鑒模板雨林","圖鑒模板特區"]
    let animalsEggName = ["ocean" , "grassland" , "rainforest" , "special"]
    
    
    
    @IBOutlet weak var zooCollectionView: UICollectionView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
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
        RecordLoad()
        backgroundImage.image = UIImage(named: animalsAreaBackgroundName[tab])
        self.zooCollectionView.reloadData()
    }
    // 草原
    @IBAction func tab2(_ sender: Any) {
        tab = 1
        RecordLoad()
        backgroundImage.image = UIImage(named: animalsAreaBackgroundName[tab])
        self.zooCollectionView.reloadData()
    }
    // 雨林
    @IBAction func tab3(_ sender: Any) {
        tab = 2
        RecordLoad()
        backgroundImage.image = UIImage(named: animalsAreaBackgroundName[tab])
        self.zooCollectionView.reloadData()
    }
    // 特區
    @IBAction func tab4(_ sender: Any) {
        tab = 3
        RecordLoad()
        backgroundImage.image = UIImage(named: animalsAreaBackgroundName[tab])
        self.zooCollectionView.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return animalsNameArray[tab].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ZooCollectionCell
        if animalsNameArray[0].isEmpty == true || animalsNameArray[1].isEmpty == true || animalsNameArray[2].isEmpty == true || animalsNameArray[3].isEmpty == true{
            cell.animalImage.image = UIImage(named: animalsEggName[tab])
        }else{
            
            switch tab {
            case 0 :
                if indexPath.row < self.oceanCount {
                    let reference = storageRef.child("Animals/\(animalsNameArray[tab][indexPath.row]).png")
                    cell.animalImage.sd_setImage(with: reference, placeholderImage: UIImage(named:  animalsEggName[tab]))
                }else{
                    cell.animalImage.image = UIImage(named: animalsEggName[tab])
                }
                break
            case 1 :
                if indexPath.row < self.grassLandCount {
                    let reference = storageRef.child("Animals/\(animalsNameArray[tab][indexPath.row]).png")
                    cell.animalImage.sd_setImage(with: reference, placeholderImage: UIImage(named:  animalsEggName[tab]))
                }else{
                    cell.animalImage.image = UIImage(named: animalsEggName[tab])
                }
                break
            case 2 :
                if indexPath.row < self.rainForestCount {
                    let reference = storageRef.child("Animals/\(animalsNameArray[tab][indexPath.row]).png")
                    cell.animalImage.sd_setImage(with: reference, placeholderImage: UIImage(named:  animalsEggName[tab]))
                }else{
                    cell.animalImage.image = UIImage(named: animalsEggName[tab])
                }
                break
            case 3 :
                if indexPath.row < self.cnt {
                    let reference = storageRef.child("Animals/\(animalsNameArray[tab][indexPath.row]).png")
                    cell.animalImage.sd_setImage(with: reference, placeholderImage: UIImage(named:  animalsEggName[tab]))
                }else{
                    cell.animalImage.image = UIImage(named: animalsEggName[tab])
                }
                break
            default :
                print("Something is Wrong")
                break
            }
            
            
            
        }
      
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ZooCollectionPopController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ZooCollectionPopController") as? ZooCollectionPopController
        ZooCollectionPopController?.animalsName = animalsNameArray[tab][indexPath.row] as? String
        ZooCollectionPopController?.animalsIntro = animalsIntroArray[tab][indexPath.row] as? String
        ZooCollectionPopController?.animalsAreaName = animalsAreaName[tab]
        present(ZooCollectionPopController!, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        backgroundImage.image = UIImage(named: animalsAreaBackgroundName[tab])
        animalsLoads()
        RecordLoad()
    }
    
    func RecordLoad(){
        //各區累積里程數歸零（海洋、草原、雨林、全區）
        self.accumulatedDistance = 0.0
        self.oceanAccumulatedDistance = 0.0
        self.grassLandAccumulatedDistance = 0.0
        self.rainForestAccumulatedDistance = 0.0
        
        self.oceanCount = 0
        self.grassLandCount = 0
        self.rainForestCount = 0
        self.cnt = 0
        
        self.ref?.child("Records/\(self.currentID!)").observe(.childAdded, with: { (snapshot) in
            let values = snapshot.value as! [String : AnyObject]
            
            //各區累積里程數轉單位為公里（海洋、草原、雨林、全區）
            let oceanDistanceToKilometers = (values["oceanDistance"] as! Double) / 1000
            let grassLandDistanceToKilometers = (values["grassLandDistance"] as! Double) / 1000
            let rainForestDistanceToKilometers = (values["rainForestDistance"] as! Double) / 1000
            let distanceToKilometers = (values["distance"] as! Double) / 1000
            
           
            //各區里程數累積（海洋、草原、雨林、全區）
            self.oceanAccumulatedDistance += oceanDistanceToKilometers
            self.grassLandAccumulatedDistance += grassLandDistanceToKilometers
            self.rainForestAccumulatedDistance += rainForestDistanceToKilometers
            self.accumulatedDistance += distanceToKilometers
            
            //各區動物數（海洋、草原、雨林、全區）
            self.oceanCount =  (Int(self.oceanAccumulatedDistance) / 5)
            self.grassLandCount = (Int(self.grassLandAccumulatedDistance) / 5)
            self.rainForestCount = (Int(self.rainForestAccumulatedDistance) / 5)
            self.cnt = (Int(self.accumulatedDistance) / 5)
            
            self.zooCollectionView.reloadData()
        })
    }
    
    func animalsLoads (){
        Database.database().reference().child("animals").observe(.value) { (snapshot) in
            self.animalsNameArray[0] = []
            self.animalsNameArray[1] = []
            self.animalsNameArray[2] = []
            self.animalsNameArray[3] = []
            self.animalsIntroArray[0] = []
            self.animalsIntroArray[1] = []
            self.animalsIntroArray[2] = []
            self.animalsIntroArray[3] = []
            let data = snapshot.value as! [String : AnyObject]
            for area in data.keys {
                switch area {
                case "海洋區":
                    let animals = data[area] as! [String : AnyObject]
                    for key in animals.keys {
                        let aAnimal = animals[key] as! [String : Any]
                        let animalName = aAnimal["name"] as! String
                        self.animalsNameArray[0].append(animalName)
                        let animalIntro = aAnimal["intro"] as! String
                        self.animalsIntroArray[0].append(animalIntro)
                        
                    }
                    
                    break
                case "草原區":
                    let animals = data[area] as! [String : AnyObject]
                    for key in animals.keys {
                        let aAnimal = animals[key] as! [String : Any]
                        let animalName = aAnimal["name"] as! String
                        self.animalsNameArray[1].append(animalName)
                        let animalIntro = aAnimal["intro"] as! String
                        self.animalsIntroArray[1].append(animalIntro)
                    }
                    break
                case "雨林區":
                    let animals = data[area] as! [String : AnyObject]
                    for key in animals.keys {
                        let aAnimal = animals[key] as! [String : Any]
                        let animalName = aAnimal["name"] as! String
                       self.animalsNameArray[2].append(animalName)
                        let animalIntro = aAnimal["intro"] as! String
                        self.animalsIntroArray[2].append(animalIntro)
                    }
                    break
                case "特區" :
                    let animals = data[area] as! [String : AnyObject]
                    for key in animals.keys {
                        let aAnimal = animals[key] as! [String : Any]
                        let animalName = aAnimal["name"] as! String
                       self.animalsNameArray[3].append(animalName)
                        let animalIntro = aAnimal["intro"] as! String
                        self.animalsIntroArray[3].append(animalIntro)
                    }
                    break
                default:
                    print("something is wrong")
                    break
                }
            }
            self.zooCollectionView.reloadData()
        }
    }
    
}
