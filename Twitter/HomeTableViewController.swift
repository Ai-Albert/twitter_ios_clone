//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by Albert Ai on 10/3/21.
//  Copyright © 2021 Dan. All rights reserved.
//

import UIKit
import SystemConfiguration

class HomeTableViewController: UITableViewController {
    
    var tweetsArray = [NSDictionary]()
    var numberofTweets: Int!
    let tweetsRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTweets()
        tweetsRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = tweetsRefreshControl
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadTweets()
    }
    
    // Tweet loading stuff
    
    @objc func loadTweets() {
        let tweetsURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        numberofTweets = 20
        let params = ["count": numberofTweets]
        TwitterAPICaller.client?.getDictionariesRequest(url: tweetsURL, parameters: params as [String : Any], success: { (tweets: [NSDictionary]) in
            self.tweetsArray.removeAll()
            for tweet in tweets {
                self.tweetsArray.append(tweet)
            }
            self.tableView.reloadData()
            self.tweetsRefreshControl.endRefreshing()
        }, failure: { (Error) in
            print("Could not retrieve tweets")
        })
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row + 1 == tweetsArray.count) {
            loadMoreTweets()
        }
    }
    
    func loadMoreTweets() {
        let tweetsURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        numberofTweets += 20
        let params = ["count": numberofTweets]
        TwitterAPICaller.client?.getDictionariesRequest(url: tweetsURL, parameters: params as [String : Any], success: { (tweets: [NSDictionary]) in
            self.tweetsArray.removeAll()
            for tweet in tweets {
                self.tweetsArray.append(tweet)
            }
            self.tableView.reloadData()
        }, failure: { (Error) in
            print("Could not retrieve tweets")
        })
    }
    
    @IBAction func onLogout(_ sender: Any) {
        TwitterAPICaller.client?.logout()
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
        self.dismiss(animated: true, completion: nil)
    }
    
    // TableView stuff
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetCellTableViewCell
        
        let user = tweetsArray[indexPath.row]["user"] as! NSDictionary
        cell.userNameLabel.text = user["name"] as? String
        cell.tweetContent.text = tweetsArray[indexPath.row]["text"] as? String
        
        let imageURL = URL(string: user["profile_image_url_https"] as! String)
        let data = try? Data(contentsOf: imageURL!)
        if let imageData = data {
            cell.profileImageView.image = UIImage(data: imageData)
        }
        
        cell.setFavorite(tweetsArray[indexPath.row]["favorited"] as! Bool)
        cell.setRetweeted(tweetsArray[indexPath.row]["retweeted"] as! Bool)
        cell.tweetId = tweetsArray[indexPath.row]["id"] as! Int
        
        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetsArray.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
