import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    
    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        // make, configure and show window window
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.backgroundColor = UIColor.blackColor()
        window?.rootViewController = NavigationController(rootViewController: StreamViewController())
        window?.makeKeyAndVisible()
        return true
    }

}

