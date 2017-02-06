//
//  MovieViewerController.swift
//  MovieViewer
//
//  Created by Bconsatnt on 2/5/17.
//  Copyright © 2017 Bconsatnt. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MovieViewerController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var movies : [NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view.
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
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
                    self.tableView.reloadData()
                }
            }
        }
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
//        let cell = UITableViewCell()
        let movie = movies[indexPath.row]
            
        //set title
        if let title = movie["title"] as? String {
            cell.title.text = title
        } else { cell.title = nil }
        
        //set overview
        if let overview = movie["overview"] as? String {
            cell.overview.text = overview
        } else { cell.overview = nil }
            
        //set image
        if let poster_path = movie["poster_path"] as? String {
            let base_url = "https://image.tmdb.org/t/p/w500/"
            let posterURL = URL(string: base_url + poster_path)!
            cell.imageCell.setImageWith(posterURL)
        } else { cell.imageCell = nil }
        
        return cell
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
