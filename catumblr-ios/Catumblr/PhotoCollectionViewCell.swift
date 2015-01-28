import UIKit

private let photoLoadingOperationQueue = NSOperationQueue()

class PhotoCollectionViewCell: UICollectionViewCell {
    var photo: Post.Photo? = nil
    
    private let imageView = UIImageView()
    private let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    private var loadOperation: PhotoLoadOperation?
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // configure image view
        self.imageView.contentMode = .ScaleAspectFill
        self.imageView.clipsToBounds = true
        self.imageView.layer.borderWidth = 1.0;
        self.imageView.layer.cornerRadius = 3.5;
        self.imageView.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3).CGColor
        self.imageView.alpha = 0.0
        
        
        // configure activity indicator view
        self.activityIndicatorView.hidesWhenStopped = true
        self.activityIndicatorView.alpha = 0.4
        
        // attach subviews
        self.contentView.addSubview(self.activityIndicatorView)
        self.contentView.addSubview(self.imageView)
        
        // attach constraints
        self.imageView.snp_makeConstraints { make in
            make.edges.equalTo(self.contentView)
            return
        }
        self.activityIndicatorView.snp_makeConstraints { make in
            make.center.equalTo(self.contentView)
            return
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // cancel and clear any pending load operation
        self.loadOperation?.cancel()
        self.loadOperation = nil
        
        // reset image and alpha
        self.imageView.stopAnimating()
        self.imageView.animationImages = nil
        self.imageView.animationDuration = 0.0
        self.imageView.image = nil
        self.imageView.alpha = 0.0
        
        // stop activity indicator view animation
        self.activityIndicatorView.stopAnimating()
    }
    
    override var highlighted: Bool {
        get {
            return super.highlighted
        }
        set {
            super.highlighted = newValue
            if newValue {
                self.imageView.layer.borderColor = UIColor.whiteColor().colorWithAlphaComponent(0.5).CGColor
            } else {
                self.imageView.layer.borderColor = UIColor.whiteColor().colorWithAlphaComponent(0.3).CGColor
            }
        }
    }
    
    func reloadData(loadResources: Bool = true) {
        if loadResources {
            self.activityIndicatorView.startAnimating()
            
            if let photo = self.photo {
                
                // create operation
                let operation = PhotoLoadOperation(url: photo.url)
                
                // set operation completion block
                // this block captures self and operation weakly to avoid retain cycles
                operation.completionBlock = { [weak self, weak operation] in
                    
                    // get strong self and strong operation
                    let strongSelf = self
                    let strongOperation = operation
                    
                    // only continue if both the cell and operation are valid
                    if strongSelf != nil && strongOperation != nil {
                        
                        // operation was cancelled so bail
                        if strongOperation!.cancelled {
                            return
                        }
                        
                        if strongOperation!.image != nil {
                            strongSelf!.reloadWithImage(strongOperation!.image!)
                        } else if strongOperation!.animatedImage != nil {
                            strongSelf!.reloadWithAnimatedImage(strongOperation!.animatedImage!)
                        } else {
                            strongSelf!.reloadWithNoImage()
                        }
                    }
                }
                
                // assign load operation
                self.loadOperation = operation
                
                // add operation to queue
                photoLoadingOperationQueue.addOperation(operation)
            }
        }
    }
    
    private func reloadWithImage(image: UIImage) {
        // set image
        self.imageView.animationImages = nil
        self.imageView.animationDuration = 0.0
        self.imageView.stopAnimating()
        self.imageView.image = image
        
        // fade in
        UIView.animateWithDuration(0.25) {
            self.imageView.alpha = 1.0
        }
        
        self.activityIndicatorView.stopAnimating()
    }
    
    private func reloadWithAnimatedImage(image: AnimatedImage) {
        // set image
        self.imageView.animationImages = nil
        self.imageView.animationDuration = 0.0
        self.imageView.stopAnimating()
        
        var animationImages = Array<UIImage>()
        for frame in image.frames {
            animationImages.append(frame.image)
            self.imageView.animationDuration += frame.duration
        }
        self.imageView.animationImages = animationImages
        self.imageView.image = animationImages[0]
        if self.imageView.animationDuration > 0.0 {
            self.imageView.startAnimating()
        }
        
        // fade in
        UIView.animateWithDuration(0.25) {
            self.imageView.alpha = 1.0
        }
        
        self.activityIndicatorView.stopAnimating()
    }
    
    private func reloadWithNoImage() {
        self.imageView.animationImages = nil
        self.imageView.stopAnimating()
        self.imageView.image = nil
        
        // fade in
        UIView.animateWithDuration(0.25) {
            self.imageView.alpha = 1.0
        }
        
        self.activityIndicatorView.stopAnimating()
    }
    
}