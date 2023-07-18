//
//  ViewController.swift
//  Delivery
//
//  Created by Tamara Nastevska on 7/17/23.
//  Copyright © 2023 Tamara Nastevska. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var MyCollectionView: UICollectionView!
    @IBOutlet weak var pages: UIPageControl!
    @IBOutlet weak var joinBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    var imageArray = ["img1", "img2", "img3"]
    var titleArray = ["Organize your lunch break!", "Fast and quick delivery", "Right to your door"]
    var descArray = ["With our on time delivery never spend a time buying food, you got it at the time you want!", "With our on time delivery never spend a time buying food, you got it at the time you want!", "With our on time delivery never spend a time buying food, you got it at the time you want!"]
    var index = 0
    var reachedLastSlide = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MyCollectionView.dataSource = self
        MyCollectionView.delegate = self
        nextBtn.addTarget(self, action: #selector(nextBtnTapped(_:)), for: .touchUpInside)
        joinBtn.isHidden = true
        loginBtn.isHidden = true
        pages.numberOfPages = imageArray.count
        pages.currentPage = index
        
        applyButtonStyling(joinBtn)
        applyButtonStyling(nextBtn)
        applyButtonStyling(loginBtn)
    }
    private func applyButtonStyling(_ button: UIButton) {
        button.layer.cornerRadius = 15
        button.layer.shadowColor = UIColor.lightGray.cgColor
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize(width: 0, height: 5)
        button.layer.shadowRadius = 10
    }
   @objc func scrollingSetup() {
        let visibleRect = CGRect(origin: MyCollectionView.contentOffset, size: MyCollectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = MyCollectionView.indexPathForItem(at: visiblePoint) else { return }
        index = indexPath.row
        pages.currentPage = index
    }


    @IBAction func nextBtnTapped(_ sender: UIButton) {
        let currentIndex = index
        let nextIndex = currentIndex + 1
        if nextIndex < imageArray.count {
            index = nextIndex
            MyCollectionView.scrollToItem(at: IndexPath(item: nextIndex, section: 0), at: .right, animated: true)
            pages.currentPage = nextIndex
            if nextIndex == imageArray.count - 1 {
            // Show the join and login buttons
            joinBtn.isHidden = false
            loginBtn.isHidden = false
            nextBtn.isHidden = true
            reachedLastSlide = true
            MyCollectionView.isScrollEnabled = false
                
        }
    }
}
    
}
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCell", for: indexPath) as? CustomCollectionViewCell
        cell?.imgView.image = UIImage(named: imageArray[indexPath.row])
        cell?.title.text = titleArray[indexPath.row]
        cell?.desc.text = descArray[indexPath.row]
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
           scrollingSetup()
        if index == imageArray.count - 1 {
            nextBtn.isHidden = true
            joinBtn.isHidden = false
            loginBtn.isHidden = false
            reachedLastSlide = true
        } else {
            nextBtn.isHidden = false
            joinBtn.isHidden = true
            loginBtn.isHidden = true
            reachedLastSlide = false
        }
        if reachedLastSlide {
            MyCollectionView.isScrollEnabled = false
        } else {
            MyCollectionView.isScrollEnabled = true
        }
       }
}

