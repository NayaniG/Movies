//
//  Screen1ViewController.swift
//  Movies
//
//  Created by SJI-GOA-79 on 19/12/22.
//

import UIKit
import Realm
import RealmSwift

class Screen1ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var loadMoreButton: UIButton!
    
    var displayData = MoviesData()
    var moviesItems = List<Items>()
    var displayCount: Int = 0
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AuthService.shared.observeAuthEvents()
        AuthService.shared.fetchCurrentAuthSession()
        
        print("AuthService.shared.isSignedIn  3: \(AuthService.shared.isSignedIn)")
                            
        setupUI()
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func setupUI() {
                
        do {
            try! realm.write {
                let fetchedData = realm.objects(MoviesData.self)
                self.moviesItems = fetchedData[0].items
            }
            
        } catch {
            print("error: \(error)")
        }

        print("displayCount: \(displayCount)")

        self.displayCount = MovieManager.shared.getDisplayCount(currentCount: displayCount, moviesItemsCoutnt: moviesItems.count)

        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }

        
        self.navigationItem.setHidesBackButton(true, animated: true)
        collectionView.register(UINib(nibName: "collectionViewCell", bundle: nil), forCellWithReuseIdentifier: "collectionViewCell")
    }
    
    
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func didTapLogoutButton(_ sender: UIButton) {
        AuthService.shared.signOutLocally()
        AuthService.shared.observeAuthEvents()
        AuthService.shared.fetchCurrentAuthSession()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapLoadMore(_ sender: UIButton) {
        
        self.displayCount = MovieManager.shared.getDisplayCount(currentCount: displayCount, moviesItemsCoutnt: moviesItems.count)
        
        if displayCount == 250 {
            sender.isHidden = false
        } else {
            sender.isHidden = true
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    
    // MARK: - Alert message
    func showAlertWith(title: String, message: String, style: UIAlertController.Style = .alert) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
}

extension Screen1ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as? collectionViewCell
        
        let title = moviesItems[indexPath.row].title
        let imageURL = moviesItems[indexPath.row].image
        let url = URL(string: imageURL!)
        
        cell?.imageView.downloaded(from: url!)
        cell?.movieTitle.text = title
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layoutcollectionViewLayout:UICollectionViewLayout, sizeForItemAt indexpath:IndexPath) -> CGSize {
        
        let numberOfItemsPerRow: CGFloat = 2.0
        let width = (collectionView.frame.width)/numberOfItemsPerRow
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Clicked on ID: \(moviesItems[indexPath.row].id!)")
        
        if let screen2VC = UIStoryboard.auth
            .instantiateViewController(withIdentifier: "Screen2ViewController") as? Screen2ViewController {
            screen2VC.modalPresentationStyle = .fullScreen
            self.navigationItem.setHidesBackButton(true, animated: true)
            self.navigationController?.navigationBar.isHidden = true
            screen2VC.movieId = moviesItems[indexPath.row].id!
            self.navigationController?.pushViewController(screen2VC, animated: true)
        }
    }
}

extension Screen1ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewHeight = scrollView.frame.size.height
        let scrollContentSizeHeight = scrollView.contentSize.height
        let scrollOffset = scrollView.contentOffset.y
        
        if (scrollOffset + scrollViewHeight == scrollContentSizeHeight) {
            self.loadMoreButton.isHidden = false
            if self.displayCount == 250 {
                self.loadMoreButton.isHidden = true
            }
        } else {
            self.loadMoreButton.isHidden = true
        }
    }
}


