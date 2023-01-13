//
//  Screen2ViewController.swift
//  Movies
//
//  Created by SJI-GOA-79 on 27/12/22.
//

import UIKit
import RealmSwift

class Screen2ViewController: UIViewController {
    
    @IBOutlet weak var castCollectionView: UICollectionView!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var plot: UITextView!
    
    var movieDetailsManager = MovieDetailsManager()
    var movieId: String = ""
    var movieData = MoviesDetails()
    lazy var realm:Realm = {
        return try! Realm()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
    
        MovieDetailsManager.shared.getMovieDetails(movieId: movieId) { result in
            print("result: \(result)")
            self.movieData = result
            DispatchQueue.main.async {
                self.castCollectionView.dataSource = self
                self.castCollectionView.delegate = self
                self.castCollectionView.reloadData()
                self.castCollectionView.register(UINib(nibName: "CastCell", bundle: nil), forCellWithReuseIdentifier: "CastCell")
            }
            
            
            DispatchQueue.main.async { [self] in
                
                let url = URL(string: movieData.image!)
                self.movieImage.downloaded(from: url!)
                self.movieTitle.text = movieData.title
                self.rating.text = movieData.imDbRating
                self.plot.text = movieData.plot
                
                let dateText = movieData.releaseDate
                var dateArr = dateText?.split(separator: "-")
                let dd = dateArr![2]
                let mm = dateArr![1]
                let yyy = dateArr![0]
                self.date.text = "\(dd)-\(mm)-\(yyy)"
                
                print("movieData.actorList?.count: \(self.movieData.actorList.count)")
            }
        }
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}


extension Screen2ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        print("COLLECTIONVIEW")

        return self.movieData.actorList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CastCell", for: indexPath) as? CastCell
        let image = movieData.actorList[indexPath.row].image
        let actorName = movieData.actorList[indexPath.row].name
        let url = URL(string: image!)
        cell?.castImage.downloaded(from: url!)
        cell?.actorName.text = actorName
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layoutcollectionViewLayout:UICollectionViewLayout, sizeForItemAt indexpath:IndexPath) -> CGSize {
        
        return CGSize(width: 120, height: 120)
    }
}


