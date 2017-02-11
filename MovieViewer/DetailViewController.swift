//
//  DetailViewController.swift
//  MovieViewer
//
//  Created by Bconsatnt on 2/7/17.
//  Copyright © 2017 Bconsatnt. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    
    var movie : NSDictionary!
    var refreshControl : UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(movie)
        scroll.contentSize = CGSize(width: scroll.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        //set title
        if let title = movie["title"] as? String {
            titleLabel.text = title
        } else { titleLabel.text = nil }
        
        //set overview
        if let overview = movie["overview"] as? String {
            overviewLabel.text = overview
            overviewLabel.sizeToFit()
        } else { overviewLabel.text = nil }
        
        //set image
        if let poster_path = movie["poster_path"] as? String {
            let base_url = "https://image.tmdb.org/t/p/w500/"
            let posterURL = String(base_url + poster_path)!
            let imageRequest = NSURLRequest(url: NSURL(string: posterURL)! as URL)
            imageView.setImageWith(imageRequest as URLRequest,
                                        placeholderImage: nil,
                                        success: { (imageRequest, imageResponse, image) -> Void in
                                            
                                            // imageResponse will be nil if the image is cached
                                            if (imageResponse != nil) {
                                                print("Image was NOT cached, fade in image")
                                                self.imageView.alpha = 0.0
                                                self.imageView.image = image
                                                UIView.animate(withDuration: 1, animations: { () -> Void in
                                                    self.imageView.alpha = 1.0
                                                })
                                            } else {
                                                print("Image was cached so just update the image")
                                                self.imageView.image = image
                                            }
                },
                                        failure: { (imageRequest, imageResponse, error) -> Void in
                                            // do something for the failure condition
            })
        } else { imageView = nil }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
