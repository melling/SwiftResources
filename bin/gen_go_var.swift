#!/usr/bin/env xcrun swift

//
//  main.swift
//  h4Tools
//
//  Created by Michael Mellinger on 2/20/15.
//  Copyright (c) 2015 h4labs. All rights reserved.
//

import Foundation

var allTags:[String:Int] = [:]

let groupNumbers = [
    "sites": 1,
    "beginner" : 2,
    "tutorial" : 3,
    "source" : 4,
    "lib" : 5,
    "libs" : 5,
    "playground" : 6,
    "advanced" : 7,
    "commercial" : 8
]

class UrlRecord {
    var id: Int
    var groupNum: Int
    var source: String
    var url: String
    var title: String
    var githubName: String
    var tags: String
    var image: String
    var date: Int
    var isPaywall: Int
    var recType: Int

    init(id: Int, groupNum: Int, source: String, url: String, title: String, githubName: String, tags: String, image: String, date: Int, isPaywall: Int, recType: Int) {
        
        self.id = id
        self.groupNum = groupNum
        self.source = source
        self.url = url
        self.title = title
        self.githubName = githubName
        self.tags = tags
        self.image = image
        self.date = date
        self.isPaywall = isPaywall
        self.recType = recType
    }
}

var database:[UrlRecord] = []

func readLines(filePath: String) -> [String] {
    //    var stream:NSStream = NSStream
    
    var allLines:[String] = []
    
    if let fileManager =  NSFileManager.defaultManager() as NSFileManager! {
        let fileExists = fileManager.fileExistsAtPath(filePath)
        if fileExists {
            let data:NSData? = fileManager.contentsAtPath(filePath)
            
            let aString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            
            let str1:String = aString as! String
            allLines = str1.componentsSeparatedByString("\n")
            
        } else {
            print("file not found: \(filePath)")
        }
        
        
    }
    return allLines
    
}

func writeGoVar(groupNum: Int, url: String, name: String,
    source: String, githubName:String, 
    tags: String, image: String, date: Int,
     isPaywall: Int, recType: Int) {
        var allTagStr = ""

        let lowerTitle = name.lowercaseString
        let tagList = tags.componentsSeparatedByString(":")
        for t in tagList {
            if t != "" {

                allTagStr += "\"\(t)\","
            }
      }
        print("{\(groupNum), \"\(url)\",\"\(name)\",\"\(lowerTitle)\" ,\"\(source)\", \"\(githubName)\", []string{\(allTagStr)}, \"\(image)\", \(date), \(isPaywall), \(recType)  },")
}

func deriveSource(url: String) -> (String, String) {
    
    var source = "n/a"
    var githubName = ""
    var F:[String] // Translated from Perl?
    let F0 = url.componentsSeparatedByString("//")
    let url0:String = F0[1]
    F = url0.componentsSeparatedByString("/")
    if url.rangeOfString("github.com") != nil {
        source = "github.com/" + F[1]
        // githubName = url0.stringByReplacingOccurrencesOfString("github.com/", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        githubName = F.last!
        if githubName == "README.md" {
            githubName = ""
        }
    } else if url.hasPrefix("http") { //(url =~ m#^http://([a-zA-Z0-9.\-\!\#]*)/#) {
        
        source = F[0].stringByReplacingOccurrencesOfString("www.", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil) //  source =~ s/www[.]//;
    } else {
        source = url
        //    source =~ s/http:\/\///;
        //    my @F = split(/\//, url);
        
        //    # my @F = split(source,'/');
        source = F[0]
    }
    return (source, githubName)
}

let lines = readLines("/tmp/swift_urls.tsv")
var allUrls:[String:Int] = [:]

var ok:Int
var i=1
for line in lines {
    //    ok = false
    if !(line.hasPrefix("#") || line.hasPrefix(" ")) {
        let aLine = line.componentsSeparatedByString("\t")
        if aLine.count > 1 {
            
            if let groupNum = groupNumbers[aLine[0]] {
                let url = aLine[1]
                var (source, githubName) = deriveSource(url)
                // TODO: Check for trailing / and http vs https
                if let exists = allUrls[url] {
                    print("Error: Duplicate URL: \(url)")
                } else {
                    allUrls[url]=1
                }
                let title = aLine[2]
                let tags = aLine[3]
                let image = aLine[4]
                var date:Int? = Int(aLine[5])
                if (date == nil) {
                    date = 20010101
                }

                var isPaywall:Int? = Int(aLine[6])

                if (isPaywall == nil) {
                    isPaywall = 0
                }

                var recType:Int? = Int(aLine[7])

                if (recType == nil) {
                    recType = 0
                }
                let rec = UrlRecord(id: i, groupNum: groupNum, source: source, url: url, title: title, githubName: githubName, tags: tags, image: image, date: date!, isPaywall: isPaywall!, recType: recType!)
                database.append(rec)
                
                
            } else {
                print("Error: Invalid Group: \(line)")
            }
        } else {
            //            print("Error: Not enough values on line: \(line)")
        }
    }
    i++
}

func printTagsArray() {
    
    let names = allTags.keys.sort( { $0.lowercaseString < $1.lowercaseString } )
    
    let varName = "var tagNameList = []string{"
    
    print("\(varName)")
    for name in names {
        print("\"\(name)\",", terminator:" ")
    }
    print("}")
    
}

func printTagCountVar() {
    print("var tagCountDict = map[string]int{")
    for (key, value) in allTags.sort({ $0.0.lowercaseString < $1.0.lowercaseString }) {
        //    let count = allTags[t]
        print("\"\(key)\": \(value),")
    }
    print("}")
}

database.sortInPlace({ (rec1, rec2) -> Bool in
    if rec1.groupNum < rec2.groupNum {
        return true
    } else if rec1.groupNum == rec2.groupNum {
        
        if rec1.date > rec2.date { // most recent first
            return true
        } else if rec1.date == rec2.date {
            if rec1.source < rec2.source { // &&
                return true
            }
        } else if rec1.source == rec2.source {
            if rec1.source > rec2.source{ // most recent first
                return true
            }
        }
    }
    return false
})

print("package webserver\n")
print(" var urlList = []SwiftRec{")


for row in database {

    let tagList = row.tags.componentsSeparatedByString(":")
    for tag in tagList {
        if tag != "" {
            if let x = allTags[tag] {
                allTags[tag] = x + 1
            } else {
                allTags[tag] = 1
            }
        }
    }
    
    writeGoVar(row.groupNum, url:row.url, name:row.title, source:row.source, githubName: row.githubName, tags:row.tags,
     image:row.image, date:row.date,
      isPaywall:row.isPaywall, recType: row.recType)
}
print("}")

printTagsArray()
printTagCountVar()

