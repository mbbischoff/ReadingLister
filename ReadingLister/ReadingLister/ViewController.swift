//
//  ViewController.swift
//  ReadingLister
//
//  Created by Matthew Bischoff on 5/30/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    let username = ""
    let password = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let userPasswordString = "\(username):\(password)"
        
        let userPasswordData = userPasswordString.dataUsingEncoding(NSUTF8StringEncoding)
        let base64EncodedCredential = userPasswordData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        
        let authString = "Basic \(base64EncodedCredential)"
        config.HTTPAdditionalHeaders = ["Authorization" : authString]
        let session = NSURLSession(configuration: config)
        
        guard let URLStrings = allReadingListURLStrings() else { return }
        
        for URLString in URLStrings {
            let baseRequestURL = NSURL(string: "https://www.instapaper.com/api/add")!
        
            let URLComponents = NSURLComponents(URL: baseRequestURL, resolvingAgainstBaseURL: false)
            URLComponents?.queryItems = [NSURLQueryItem(name: "url", value: URLString)]
            
            let request = NSURLRequest(URL: URLComponents!.URL!)
            
            let task = session.dataTaskWithRequest(request) { (data, response, error) in
                print(response)
                let responseData = String(data: data!, encoding: NSUTF8StringEncoding)
                print(responseData)
            }
            task.resume()
        }
    }
    
    func allReadingListURLStrings() -> [String]? {
        let libraryDirectory = NSFileManager.defaultManager().URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask).first
        let bookmarksURL = libraryDirectory?.URLByAppendingPathComponent("Safari/Bookmarks.plist") ?? NSURL()
        
        let data = NSData(contentsOfURL: bookmarksURL) ?? NSData()
        
        let plist = try? NSPropertyListSerialization.propertyListWithData(data, options: .Immutable, format: nil)
        
        guard let root = plist as? [String: AnyObject] else { return nil }
        
        guard let children = root["Children"] as? [[String: AnyObject]] else { return nil }
        
        let readingLists = children.filter { child in
            return child["Title"] as? String == "com.apple.ReadingList"
        }
        
        guard let readingList = readingLists.first else { return nil }
        
        guard let readingListItems = readingList["Children"] as? [[String: AnyObject]] else { return nil }
        
        let URLStrings = readingListItems.flatMap { item -> String? in
            let URLString = item["URLString"] as? String
            return URLString ?? ""
        }
        
        return URLStrings
    }
}

