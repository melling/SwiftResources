#!/usr/bin/env xcrun swift

// Import all Unix libs
import Darwin
import Foundation


func crawlSite(urlPath: String) -> String {

    var url: NSURL = NSURL(string: urlPath)!
    var request1: NSURLRequest = NSURLRequest(URL: url)
    var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
    var error: NSErrorPointer = nil
    var data: NSData =  NSURLConnection.sendSynchronousRequest(request1, returningResponse: response, error:nil)!
    let aString = NSString(data: data, encoding: NSUTF8StringEncoding)
    let htmlDocument:String = aString as String

    return htmlDocument
}

mkdir("./data", 511)

let url = "http://google.com"
mkdir("./data", 511)

let htmlDocument = crawlSite(url)
let f0 = url.componentsSeparatedByString("//")
let url0:String = f0[1]

let filePath = "data/" + url0
    
//println("\(htmlDocument)")
htmlDocument.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)

