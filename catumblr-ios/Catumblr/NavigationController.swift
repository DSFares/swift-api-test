import UIKit

class NavigationController: UINavigationController {
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributes = NSMutableDictionary()
        attributes.setObject(UIFont(name: "AvenirNext-Regular", size: 18.0)!, forKey: NSFontAttributeName)
        
        self.navigationBar.barStyle = .Black
        self.navigationBar.titleTextAttributes = attributes
    }
}
