#!/usr/bin/env xcrun swift

// Import all Unix libs
import Darwin
import Foundation

func crawlSite2(urlPath: String) -> String {

let url = NSURL(string: urlPath)
let request = NSURLRequest(URL: url!, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5.0)
//var htmlString:String = ""
var x:String = "z"

let session = NSURLSession.sharedSession()

session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
    print(data)
    // html = data as! String
      if let htmlString = NSString(data: data!, encoding:NSUTF8StringEncoding) {
        x = htmlString as String
      } else {
        x = "y"


      }
        print(response)
	    print(error)
    }).resume()
print(x)
    return x
}

//func crawlSite(urlPath: String) -> String {
//
//    var url: NSURL = NSURL(string: urlPath)!
//    var request1: NSURLRequest = NSURLRequest(URL: url)
//    var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
//    var error: NSErrorPointer = nil
//    var data: NSData =  NSURLConnection.sendSynchronousRequest(request1, returningResponse: response, error:nil)!
//    let aString = NSString(data: data, encoding: NSUTF8StringEncoding)
//    let htmlDocument:String = aString as! String
//
//    return htmlDocument
//}

mkdir("./data", 511)

let url = "http://google.com"
mkdir("./data", 511)

let htmlDocument = crawlSite2(url)
let f0 = url.componentsSeparatedByString("//")
let url0:String = f0[1]

let filePath = "data/" + url0
    
//println("\(htmlDocument)")
 do {
try htmlDocument.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding)
} catch {
    print("ERROR: Writing file")
}
