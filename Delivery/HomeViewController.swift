//
//  HomeViewController.swift
//  Delivery
//
//  Created by Tamara Nastevska on 7/18/23.
//  Copyright © 2023 Tamara Nastevska. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore
import FirebaseAnalytics

class HomeViewController: UIViewController, UICollectionViewDelegate {
    @IBOutlet weak var greetLabel: UILabel!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var foodTypeCollectionView: UICollectionView!
    @IBOutlet weak var offersForYouCollectionView: UICollectionView!
    @IBOutlet weak var bestRatedCollectionView: UICollectionView!
    
    var foodTypes: [FoodType] = []
    var offers: [Offer] = []
    var bestRated: [BestRated] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateGreeting()
        updateScrollView()
        self.offersForYouCollectionView.dataSource = self
        self.offersForYouCollectionView.delegate = self
        self.bestRatedCollectionView.dataSource = self
        self.bestRatedCollectionView.delegate = self
      
    }
  func updateGreeting() {
      if let user = Auth.auth().currentUser {
          let userUID = user.uid
          let db = Firestore.firestore()
          let usersRef = db.collection("users")

          // Query Firestore to find the user document with matching UID
          let query = usersRef.whereField("uid", isEqualTo: userUID)

          query.getDocuments { (snapshot, error) in
              if let error = error {
                  print("Error fetching user data from Firestore: \(error.localizedDescription)")
                  self.greetLabel.text = "Hi!"
                  return
              }

              if let document = snapshot?.documents.first {
                  // Extract the first name from the Firestore document
                  let firstName = document["firstname"] as? String ?? ""
                  self.greetLabel.text = "Hi, \(firstName)!"
              } else {
                  // Handle the case where the user's document is not found
                  self.greetLabel.text = "Hi!"
              }
          }
      } else {
          greetLabel.text = "Hi!"
      }
  }
    func updateScrollView() {
        if let collectionViewLayout = foodTypeCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            collectionViewLayout.scrollDirection = .horizontal
        }
        foodTypeCollectionView.isPagingEnabled = true
        
        let db = Firestore.firestore()
        let collectionRef = db.collection("food_types")
        let offerRef = db.collection("offers")
        let restaurantRef = db.collection("restaurants")
        
        collectionRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            if let documents = snapshot?.documents {
            self.foodTypes = documents.compactMap { document in
                let data = document.data()
                guard let imageURLString = data["image_url"] as? String,
                      let imageURL = URL(string: imageURLString),
                      let label = data["label"] as? String else {
                    return nil
                }
                return FoodType(imageURL: imageURL, label: label)
            }
                 print("FoodTypes array:", self.foodTypes)
                self.foodTypeCollectionView.reloadData()
                
            }
    }
         offerRef.getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching data: \(error.localizedDescription)")
                    return
                }
                if let documents = snapshot?.documents {
                self.offers = documents.compactMap { document in
                    let data = document.data()
                    guard let imageURLString = data["image_url"] as? String,
                          let imageURL = URL(string: imageURLString)else {
                        return nil
                    }
                    return Offer(imageURL: imageURL)
                }
                     print("Offers array:", self.offers)
                    self.offersForYouCollectionView.reloadData()
                    
                }
        }
        restaurantRef.getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching data: \(error.localizedDescription)")
                    return
                }
                if let documents = snapshot?.documents {
                self.bestRated = documents.compactMap { document in
                    let data = document.data()
                    guard let imageURLString = data["image_url"] as? String,
                          let imageURL = URL(string: imageURLString),
                          let name = data["name"] as? String,
                          let location = data["location"] as? String else {
                        return nil
                    }
                    return BestRated(imageURL: imageURL, name: name, location: location)
                }
                     print("Best Rated array:", self.bestRated)
                    self.bestRatedCollectionView.reloadData()
                    
                }
        }

 }
}
extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == foodTypeCollectionView {
            return foodTypes.count
        } else if collectionView == offersForYouCollectionView {
            return offers.count
        } else if collectionView == bestRatedCollectionView {
            return bestRated.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == foodTypeCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FoodTypeCell", for: indexPath) as! FoodTypeCollectionViewCell
            let foodType = foodTypes[indexPath.item]

            cell.foodTypeLabel.text = foodType.label

            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: foodType.imageURL),
                   let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        cell.FoodTypeImg.image = image
                    }
                }
            }

            return cell
        } else if collectionView == offersForYouCollectionView {
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OfferCell", for: indexPath) as! OffersForYouCollectionViewCell
            let offer = offers[indexPath.item]

            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: offer.imageURL),
                   let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        cell.offerImageView.image = image
                    }
                }
            }

            return cell
        } else if collectionView == bestRatedCollectionView {
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BestRatedCell", for: indexPath) as! BestRatedCollectionViewCell
            let best = bestRated[indexPath.item]

            cell.name.text = best.name
            cell.location.text = best.location
            
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: best.imageURL),
                   let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        cell.bestRatedImageView.image = image
                    }
                }
            }

            return cell
        }

        return UICollectionViewCell()
    }
}
