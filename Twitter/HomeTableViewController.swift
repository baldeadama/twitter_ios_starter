//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by Mamadou A. Balde on 3/11/19.
//  Copyright © 2019 MamadouABalde. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {
    
    var tweetArray = [NSDictionary]() // var, create a variable that will change
    var numberOfTweet:Int!
    
    let myRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTweets()
        myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadTweets()
    }
    //Function that called the API
    @objc func loadTweets(){
        
        numberOfTweet = 20
        
        let myUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let myParams = ["count": numberOfTweet]
        // calling the API
        TwitterAPICaller.client?.getDictionariesRequest(url: myUrl, parameters: myParams, success: {(tweets: [NSDictionary]) in
            self.tweetArray.removeAll()
            for tweet in tweets{ //Populate the tweetArray with new tweets
                self.tweetArray.append(tweet)
            }
            self.tableView.reloadData() //Reloading the data with the new content
            self.myRefreshControl.endRefreshing()
        }, failure: { (Error) in
            print("Could not retreive tweets! oh no!!")
            
        })
    }
    
    func loadMoreTweets(){
        let myUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json" // same exact url as in the function loadTweets
        numberOfTweet = numberOfTweet + 20 // increment of 20 whenever we call the function
        let myParams = ["count": numberOfTweet]
        // calling the API
        TwitterAPICaller.client?.getDictionariesRequest(url: myUrl, parameters: myParams , success: {(tweets: [NSDictionary]) in
            self.tweetArray.removeAll()
            for tweet in tweets{ //Populate the tweetArray with new tweets
                self.tweetArray.append(tweet)
            }
            self.tableView.reloadData() //Reloading the data with the new content
            //self.myRefreshControl.endRefreshing() //Not needed here because refreshControl will never call loadMoreTweets
        }, failure: { (Error) in
            print("Could not retreive tweets! oh no!!")
            
        })
    }
    
    // Function to be called when the user gets to the end of the page/table, then loadMoreTweets
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
        if indexPath.row + 1 == tweetArray.count{
            loadMoreTweets()
        }
    }
    
    @IBAction func onLogout( _ sender: Any) {
        TwitterAPICaller.client?.logout()
        self.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set("false", forKey: "userLoggedIn")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetCellTableViewCell
        
        // Get the username (user.name) , the content (text), and the image
        let user = tweetArray[indexPath.row]["user"] as! NSDictionary
        cell.userNameLabel.text = user["name"] as? String
        cell.tweetContent.text = tweetArray[indexPath.row]["text"] as? String
        
        let imageURL = URL(string: (user["profile_image_url_https"] as? String)!)
        let data = try? Data(contentsOf: imageURL!)
        
        if let imageData = data { // let, create a variable that won't change
            cell.profileImageView.image = UIImage(data: imageData)
        }
        
        cell.setFavorite(_isFavorited: tweetArray[indexPath.row]["favorited"] as! Bool)
        cell.tweetId = tweetArray[indexPath.row]["id"] as! Int
        
        cell.setRetweeted(_isRetweeted: tweetArray[indexPath.row]["retweeted"] as! Bool)
        
        return cell
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tweetArray.count //If i am only getting 5 tweets from Tweeter, return or create 5 tweets or rows in my table
    }
    
}
