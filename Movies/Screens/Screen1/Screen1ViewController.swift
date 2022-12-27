//
//  Screen1ViewController.swift
//  Movies
//
//  Created by SJI-GOA-79 on 19/12/22.
//

import UIKit

class Screen1ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var movieManager = MovieManager()
    var data = [Items]()
                
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        movieManager.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func setupUI() {
        
        MovieManager.sharedObj.getMovies { result in
            print("result: \(result)")
            self.data = result
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        self.navigationItem.setHidesBackButton(true, animated: true)
        collectionView.register(UINib(nibName: "collectionViewCellCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "collectionViewCellCollectionViewCell")
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        AuthService.shared.signOutLocally()
        AuthService.shared.fetchCurrentAuthSession()
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func didTapLogoutButton(_ sender: UIButton) {
        AuthService.shared.signOutLocally()
        AuthService.shared.fetchCurrentAuthSession()
        self.navigationController?.popViewController(animated: true)
    }
}

extension Screen1ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        print("data.count: \(data.count)")
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCellCollectionViewCell", for: indexPath) as? collectionViewCellCollectionViewCell
                
        let id = data[indexPath.row].id
        let title = data[indexPath.row].title
        let imageURL = data[indexPath.row].image
        
        do {
            let url = try URL(string: imageURL!)
            cell?.imageView.downloaded(from: url!)
        }catch {
            print("ERRROR")
        }
                
        cell?.movieTitle.text = title
        
                
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layoutcollectionViewLayout:UICollectionViewLayout, sizeForItemAt indexpath:IndexPath) -> CGSize {
        
        let numberOfItemsPerRow: CGFloat = 2.0
        
        let width = (collectionView.frame.width)/numberOfItemsPerRow
        return CGSize(width: width, height: width) // You can change width and height here as pr your requirement
    }
    
}


extension Screen1ViewController: MoviesManagerDelegate{
    func didUpdateMovies(movies: MoviesModal) {
        print("@@movies: \(movies)")
    }
    
    
    func didFailWithError(error: Error) {
        print("@@ error:", error)
    }
    
    
}
