//
//  ViewController.swift
//  twitterclient_start
//
//  Created by Brian Voong on 2/15/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit

struct HomeStatus {
    var text:String?
    var profileImageUrl:String?
    var name:String?
    var screenName:String?
    
}

class ViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    static let cellId = "cellId"
    
    var homeStatuses:[HomeStatus]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Twitter Home"
        
        collectionView?.backgroundColor = UIColor.whiteColor()
        collectionView?.alwaysBounceVertical = true
        collectionView?.registerClass(StatusCell.self, forCellWithReuseIdentifier: ViewController.cellId)
        
        
        let twitterAPI = STTwitterAPI(OAuthConsumerKey: "oTtdnSpOkYyuKjh9ilo9FY3Y5", consumerSecret: "DUdcurDn3b6acyVCFIoN54rX5c1GJC2TU3WwA1vT4HKMEpmuyq", oauthToken: "734916355279880196-XlJu3ov44e1zzc5DM9qmjU8xkfvHvDe", oauthTokenSecret: "rFDt1wYd0dVe5rEMrtSsaeNXQODRrxVtfYEUAOsGQ7Nhp")
        
        twitterAPI.verifyCredentialsWithUserSuccessBlock({ (username, userId) in
            
            twitterAPI.getHomeTimelineSinceID(nil, count: 20, successBlock: { (statuses) in
//                print(statuses)
                
                self.homeStatuses = [HomeStatus]()
                
                for status in statuses{
                    let text = status["text"] as? String
                    
                    if let user = status["user"] as? NSDictionary {
                        let userImageUrl = user["profile_image_url_https"] as? String
                        
                        let screenName = user["screen_name"] as? String
                        
                        let name = user["name"] as? String

                        self.homeStatuses?.append(HomeStatus(text: text, profileImageUrl: userImageUrl, name: name, screenName: screenName))

                    }
                }
                
                
                self.collectionView?.reloadData()
                
                }, errorBlock: { (error) in
                    print(error)
            })
            }) { (error) in
                print(error)
        }
        
        
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = homeStatuses?.count{
            return count
        }
        return 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let statusCell = collectionView.dequeueReusableCellWithReuseIdentifier(ViewController.cellId, forIndexPath: indexPath) as! StatusCell
        
        
        
        if let homeStatus = self.homeStatuses?[indexPath.item]{
            
            statusCell.homeStatus = homeStatus
            
        }
        
        return statusCell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if let homeStatus = self.homeStatuses?[indexPath.item]{
            if let name = homeStatus.name ,screenName = homeStatus.screenName, text = homeStatus.text{
                let attributedText = NSMutableAttributedString(string: (homeStatus.name)!, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14)])
                
                attributedText.appendAttributedString(NSAttributedString(string: "\n@\(screenName)", attributes: [NSFontAttributeName:UIFont.boldSystemFontOfSize(14)]))
                
                attributedText.appendAttributedString(NSAttributedString(string: "\n\(text)", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(12)]))
                
                let size = attributedText.boundingRectWithSize(CGSizeMake(view.frame.width - 80, 1000), options: NSStringDrawingOptions.UsesFontLeading.union(NSStringDrawingOptions.UsesLineFragmentOrigin), context: nil).size
                return CGSizeMake(view.frame.width, size.height + 20 )
                
            }
        }
        return CGSizeMake(view.frame.width, 80)
        //wwww
    }

}

class StatusCell: UICollectionViewCell {
    
    var homeStatus: HomeStatus? {
        didSet{
            if let profileImageURL = homeStatus?.profileImageUrl {
                
                if let name = homeStatus?.name ,screenName = homeStatus?.screenName, text = homeStatus?.text{
                    let attributedText = NSMutableAttributedString(string: (homeStatus?.name)!, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14)])
                    
                    attributedText.appendAttributedString(NSAttributedString(string: "\n@\(screenName)", attributes: [NSFontAttributeName:UIFont.boldSystemFontOfSize(14)]))
                    
                    attributedText.appendAttributedString(NSAttributedString(string: "\n\(text)", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(12)]))
                    
                        
                    statusTextView.attributedText = attributedText
                    
                    
                }
                
                let url = NSURL(string: profileImageURL)
                
                NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
                    
                    if error != nil  {
                        print("ERROR ")
                        print(error)
                        return
                    }
                    
                    print("loading image!!!!!")
                    
                    let image = UIImage(data:data!)
                    dispatch_async(dispatch_get_main_queue(), { 
                        self.profileImageView.image = image
                    })
                    
                    
                }).resume()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let statusTextView: UITextView = {
        let textView = UITextView()
        textView.editable = false
        return textView
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFill
        return imageView
    }()
    
    let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
    }()
    
    func setupViews() {
        addSubview(statusTextView)
        addSubview(dividerView)
        addSubview(profileImageView)
        
        // constraints for statusTextView
        addConstraintsWithFormat("H:|-8-[v0(48)]-8-[v1]|", views:profileImageView, statusTextView)
        addConstraintsWithFormat("V:|[v0]|", views: statusTextView)
        
        addConstraintsWithFormat("V:|-8-[v0(48)]",views:profileImageView)
        
        // constraints for dividerView
        addConstraintsWithFormat("H:|-8-[v0]|", views: dividerView)
        addConstraintsWithFormat("V:[v0(1)]|", views: dividerView)
    }
}

extension UIView {
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerate() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}

