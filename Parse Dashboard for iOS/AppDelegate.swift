//
//  AppDelegate.swift
//  Parse Dashboard for iOS
//
//  Copyright © 2017 Nathan Tannar.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  Created by Nathan Tannar on 8/30/17.
//

import UIKit
import NTComponents
import CoreData
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Set defaults for NTComponents
        Color.Default.Tint.View = .logoTint
        Color.Default.Tint.NavigationBar = .logoTint
        Color.Default.Background.NavigationBar = .white

        Font.Default.Title = Font.Roboto.Medium.withSize(15)
        Font.Default.Subtitle = Font.Roboto.Regular.withSize(14)
        Font.Default.Body = Font.Roboto.Regular.withSize(13)
        
        // Fabric Setup
        Fabric.with([Crashlytics.self, Answers.self])
        Answers.logLogin(withMethod: String(describing: Date()), success: nil, customAttributes: nil)
        
        // Initialize the window
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        
        let appIsNew = (UserDefaults.standard.value(forKey: .appIsNew) as? Bool) ?? true
        if appIsNew {
            window?.rootViewController = UINavigationController(rootViewController: WelcomeViewController())
            window?.makeKeyAndVisible()
        } else {
            
            let split = UISplitViewController()
            split.view.backgroundColor = .white
            if UIDevice.current.userInterfaceIdiom == .phone {
                let root = UINavigationController(rootViewController: ServerViewController())
                root.navigationBar.isTranslucent = false
                root.navigationBar.tintColor = .logoTint
                if #available(iOS 11.0, *) {
                    root.navigationBar.prefersLargeTitles = true
                    root.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.semibold)]
                }
                split.viewControllers = [root]
            } else {
                let blank = UIViewController()
                blank.view.backgroundColor = .lightBlueBackground
                blank.navigationItem.leftBarButtonItem = split.displayModeButtonItem
                let root = UINavigationController(rootViewController: ServerViewController())
                root.navigationBar.tintColor = .logoTint
                root.navigationBar.isTranslucent = false
                if #available(iOS 11.0, *) {
                    root.navigationBar.prefersLargeTitles = true
                    root.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.semibold)]
                }
                split.viewControllers = [root, UINavigationController(rootViewController: blank)]
            }
            
            split.preferredDisplayMode = .allVisible
            
            window?.rootViewController = split
            window?.makeKeyAndVisible()
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Parse_Dashboard_for_iOS")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

