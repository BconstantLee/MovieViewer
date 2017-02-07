//
//  MovieViewerController.swift
//  MovieViewer
//
//  Created by Bconsatnt on 2/5/17.
//  Copyright © 2017 Bconsatnt. All rights reserved.

import UIKit
import AFNetworking
import MBProgressHUD
import SystemConfiguration

class MovieViewerController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var collectView: UICollectionView!
    @IBOutlet weak var errorView: UITextView!
    @IBOutlet weak var flow: UICollectionViewFlowLayout!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var movies : [NSDictionary] = []
    var url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")
    var refreshControl : UIRefreshControl!
    var filteredData : [NSDictionary] = []
    var searchCancel = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.red
        refreshControl.addTarget(self, action: #selector(refreshControlAction), for: UIControlEvents.valueChanged)
        collectView.insertSubview(refreshControl, at: 0)
        //modify layout
        flow.minimumLineSpacing = 0
        flow.minimumInteritemSpacing = 0
        flow.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        collectView.backgroundColor = UIColor.black
        
        collectView.dataSource = self
        collectView.delegate = self
        searchBar.delegate = self

        //check connection
        let check = isInternetAvailable()

        // Do any additional setup after loading the view.
//        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        if (check) {
            let request = URLRequest(url: self.url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
            let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
            // Display HUD right before the request is made
            MBProgressHUD.showAdded(to: self.view, animated: true)
        
            let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
                if let data = data {
                    if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
//                    print(dataDictionary)
                        self.movies = dataDictionary["results"] as! [NSDictionary]
                        self.filteredData = self.movies
                        // Hide HUD once the network request comes back (must be done on main UI thread)
                        MBProgressHUD.hide(for: self.view, animated: true)
                        //Relod
                        self.collectView.reloadData()
                    }
                }
            }
            task.resume()
        } else {
            self.errorView.isHidden = false
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        filteredData = searchText.isEmpty ? movies : movies.filter({(movie: NSDictionary) -> Bool in
            // If dataItem matches the searchText, return true to include it
            let title = movie["title"] as! String
            return title.range(of: searchText, options: .caseInsensitive) != nil
        })
        
        collectView.reloadData()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        //reset the movies displayed
        filteredData = movies
        searchCancel = true
        collectView.reloadData()
    }


    //return cell number func
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection: Int) -> Int {
            return filteredData.count
    }
    
    //update cell detail func
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCell2
//        let cell = UITableViewCell()
        let movie = filteredData[indexPath.row]
        //set title
        if let title = movie["title"] as? String {
            cell.title.text = title
        } else { cell.title = nil }
        //set image
        if let poster_path = movie["poster_path"] as? String {
            let base_url = "https://image.tmdb.org/t/p/w500/"
            let posterURL = String(base_url + poster_path)!
            let imageRequest = NSURLRequest(url: NSURL(string: posterURL)! as URL)
            cell.imageCell.setImageWith(imageRequest as URLRequest,
                                        placeholderImage: nil,
                                        success: { (imageRequest, imageResponse, image) -> Void in
                                            
                                            // imageResponse will be nil if the image is cached
                                            if (imageResponse != nil || self.searchCancel) {
                                                self.searchCancel = false
                                                print("Image was NOT cached, fade in image")
                                                cell.imageCell.alpha = 0.0
                                                cell.imageCell.image = image
                                                UIView.animate(withDuration: 1, animations: { () -> Void in
                                                    cell.imageCell.alpha = 1.0
                                                })
                                            } else {
                                                print("Image was cached so just update the image")
                                                cell.imageCell.image = image
                                            }
                },
                                        failure: { (imageRequest, imageResponse, error) -> Void in
                                            // do something for the failure condition
            })
        } else { cell.imageCell = nil }
        
        return cell
    }

    //Refresh func
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        
        // Configure session so that completion handler is executed on main UI thread
        let check = isInternetAvailable()
        if (check) {
            //hide the error messge
            self.errorView.isHidden = true
            let request = URLRequest(url: self.url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
            let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
            
            // Display HUD right before the request is made
            MBProgressHUD.showAdded(to: self.view, animated: true)
            
            let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
                if let data = data {
                    if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                        //                    print(dataDictionary)
                        self.movies = dataDictionary["results"] as! [NSDictionary]
                        
                        // Hide HUD once the network request comes back (must be done on main UI thread)
                        MBProgressHUD.hide(for: self.view, animated: true)
                        //Relod
                        self.collectView.reloadData()
                        // Tell the refreshControl to stop spinning
                        refreshControl.endRefreshing()
                    }
                }
            }
            task.resume()
        } else {
            //show the error messge
            self.errorView.isHidden = false
            MBProgressHUD.hide(for: self.view, animated: true)
            // Tell the refreshControl to stop spinning
            refreshControl.endRefreshing()
        }
    }
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
