import UIKit

// View controller that manages a collection of tumblr photo posts
class StreamViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var collectionViewLayout: UICollectionViewFlowLayout?
    var collectionView: UICollectionView?
    var refreshControl: UIRefreshControl?
    
    // MARK: UIViewController
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        // setup collection view
        self.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionViewLayout?.minimumInteritemSpacing = 8
        self.collectionViewLayout?.minimumLineSpacing = 8
        self.collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionViewLayout!)
        self.collectionView?.contentInset = UIEdgeInsetsMake(8, 0, 8, 0)
        self.collectionView?.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        self.collectionView?.indicatorStyle = UIScrollViewIndicatorStyle.White
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.collectionView?.registerClass(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "photo")
        
        // setup refresh control
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "refreshControlTriggered", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl?.tintColor = UIColor.whiteColor()
        
        // attach subviews
        self.collectionView?.addSubview(self.refreshControl!)
        view.addSubview(self.collectionView!)
        
        // attach constraints
        self.collectionView?.snp_makeConstraints { make in
            make.edges.equalTo(self.view)
            return
        }
        
        // navigation item
        self.title = TITLE
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // fetch initial posts if we have 0
        if self.posts.count == 0 {
            self.fetchInitialPosts()
        }
    }
    
    // MARK: Actions
    
    func refreshControlTriggered() {
        self.posts = Array<Post>()
        self.collectionView?.reloadData()
        self.fetchInitialPosts()
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        var width = self.view.bounds.size.width - 16.0
        if width < 0 {
            width = 1
        }
        var height = width
        if let photo = self.posts[indexPath.row].bestFittingPhotoForPixelWidth(Float(width)) {
            height = CGFloat(floor((Float(width) / Float(photo.width)) * Float(photo.height)))
        }
        return CGSizeMake(width, height)
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? PhotoCollectionViewCell {
            if let photo = cell.photo {
                let operation = PhotoLoadOperation(url: photo.url)
                weak var weakSelf = self
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    operation.start()
                    operation.waitUntilFinished()
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        if let strongSelf = weakSelf {
                            if let image = operation.image {
                                let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                                strongSelf.presentViewController(activityController, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // dequeue a cell from the collection view with the "post" reuse identifier
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photo", forIndexPath: indexPath) as? PhotoCollectionViewCell {
            cell.photo = self.posts[indexPath.row].bestFittingPhotoForPixelWidth(Float(collectionView.bounds.size.width) * Float(UIScreen.mainScreen().scale))
            cell.reloadData()
            return cell
        }
        return UICollectionViewCell()
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView!) {
        // ensure we’ve scrolled at least half way through last full screen of content
        if scrollView.contentOffset.y + scrollView.bounds.size.height >= scrollView.contentSize.height - scrollView.bounds.size.height / 2.0 {
            // ensure we’re not already fetching
            if !self.fetching && self.posts.count > 0 {
                self.fetchMorePosts()
            }
        }
    }
    
    // MARK: -
    
    private let fetchQueue = dispatch_queue_create(nil, nil)
    private var currentFetchId = 0
    private var fetching = false
    private var posts = Array<Post>()
    
    private func fetchInitialPosts() {
        // reset the current fetch id
        self.currentFetchId = 0
        
        // fetch posts
        fetchPostsBeforeTimestamp(UInt.max) { [weak self] posts, error in
            if let strongSelf = self {
                strongSelf.refreshControl?.endRefreshing()
                if error != nil {
                    UIAlertView(title: "Whoops!", message: error?.localizedDescription, delegate: nil, cancelButtonTitle: "OK").show()
                    return
                }
                
                if posts != nil {
                    strongSelf.posts = posts!
                }
                strongSelf.collectionView?.reloadData()
            }
        }
    }
    
    private func fetchMorePosts() {
        // determine the oldest post we have
        var oldestTimestamp: UInt = 0
        for post in self.posts {
            if oldestTimestamp == 0 || post.timestamp < oldestTimestamp {
                oldestTimestamp = post.timestamp
            }
        }
        
        // fetch posts
        fetchPostsBeforeTimestamp(oldestTimestamp) { [weak self] posts, error in
            if let strongSelf = self {
                strongSelf.refreshControl?.endRefreshing()
                if error != nil {
                    UIAlertView(title: "Whoops!", message: error?.localizedDescription, delegate: nil, cancelButtonTitle: "OK").show()
                    return
                }
                
                if posts?.count > 0 {
                    var indexPaths = Array<NSIndexPath>()
                    
                    for var i = 0; i < posts!.count; ++i {
                        indexPaths.append(NSIndexPath(forRow: strongSelf.posts.count + i, inSection: 0))
                    }
                    
                    strongSelf.posts += posts!
                    strongSelf.collectionView?.insertItemsAtIndexPaths(indexPaths)
                }
            }
        }
    }
    
    private func fetchPostsBeforeTimestamp(timestamp: UInt, handler: (Array<Post>?, NSError?) -> Void) {
        self.fetching = true
        
        // wrap handler closure in a new closure that ensures it fires on main queue
        let mainQueueHandler = { [weak self] (posts: Array<Post>?, error: NSError?) -> () in
            dispatch_sync(dispatch_get_main_queue()) {
                handler(posts, error)
                
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 1))
                dispatch_after(time, dispatch_get_main_queue()) {
                    self?.fetching = false
                    return
                }
            }
        }
        
        // we store the fetch id here incase of a pull to refresh we want to cancel
        let fetchId = ++self.currentFetchId
        
        // asynchronusly fetch on fetch queue
        dispatch_async(self.fetchQueue) {
            // safely copy the current posts we have & whether or not to cancel
            var posts: Array<Post>? = nil
            var cancel = false
            dispatch_sync(dispatch_get_main_queue()) {
                posts = self.posts
                cancel = (fetchId > self.currentFetchId)
            }
            
            if(cancel) {
                return
            }
            
            // get url
            let url = NSURL(string: "http://api.tumblr.com/v2/tagged?limit=20&before=\(timestamp)&tag=\(TUMBLR_FETCH_TAG)&api_key=\(TUMBLR_API_KEY)")
            
            // create request
            let req = NSMutableURLRequest(URL: url!)
            req.timeoutInterval = 15.0
            
            // execucute request
            var error: NSErrorPointer = nil
            let data = NSURLConnection.sendSynchronousRequest(req, returningResponse: nil, error: error)
            
            // check for error
            if error != nil {
                mainQueueHandler(nil, error.memory)
                return
            }
            // check for no data
            else if data == nil {
                mainQueueHandler(nil, NSError(domain: NSCocoaErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "An unknown error occured while fetching posts from tumblr."]))
                return
            }
            
            // parse JSON
            let JSON: AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.allZeros, error: error)
            
            // get JSON posts – this safely typecasts it and ensures we never can explode on invalid JSON
            let JSONPosts = (JSON as? NSDictionary as? Dictionary<String, AnyObject>)?["response"] as? NSArray as? Array<Dictionary<String, AnyObject>>
            
            // check for error
            if error != nil {
                mainQueueHandler(nil, error.memory)
                return
            }
            // check for no JSON posts
            else if JSONPosts == nil {
                mainQueueHandler(nil, NSError(domain: NSCocoaErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "An unknown error occured while parsing posts from tumblr."]))
                return
            }
            
            // convert JSON posts to post model objects
            var fetchedPosts = Array<Post>()
            for JSONPost in JSONPosts! {
                if let post = Post.fromJSONRepresentation(JSONPost) {
                    fetchedPosts.append(post)
                }
            }
            
            // finish
            mainQueueHandler(fetchedPosts, nil)
            
        }
    }

}

