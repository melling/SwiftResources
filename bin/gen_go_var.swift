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
    var apisUsed: String
    var recType: Int
    var key: Int
    
    init(id: Int, groupNum: Int, source: String, url: String, title: String, githubName: String, tags: String, image: String, date: Int, isPaywall: Int, apisUsed: String, recType: Int, key: Int) {
        
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
        self.apisUsed = apisUsed
        self.recType = recType
        self.key = key
    }
}

var database:[UrlRecord] = []

func readLines(filePath: String) -> [String] {
    //    var stream:NSStream = NSStream
    
    var allLines:[String] = []
    
    if let fileManager =  FileManager.default as FileManager! {
        let fileExists = fileManager.fileExists(atPath: filePath)
        if fileExists {
            let data:NSData? = fileManager.contents(atPath: filePath) as NSData?
            
            let aString = NSString(data: data! as Data, encoding: String.Encoding.utf8.rawValue)
            
            let str1:String = aString as! String
            allLines = str1.components(separatedBy: "\n")
            
        } else {
            print("file not found: \(filePath)")
        }
        
        
    }
    return allLines
    
}

func writeGoVar(groupNum: Int, url: String, name: String,
                source: String, githubName:String,
                tags: String, image: String, date: Int,
                isPaywall: Int, apisUsed: String,
                recType: Int, key: Int) {
    var allTagStr = ""
    
    let lowerTitle = name.lowercased()
    let tagList = tags.components(separatedBy:":")
    for t in tagList {
        if t != "" {
            
            allTagStr += "\"\(t)\","
        }
    }
    print("{\(groupNum), \"\(url)\",\"\(name)\",\"\(lowerTitle)\" ,\"\(source)\", \"\(githubName)\", []string{\(allTagStr)}, \"\(image)\", \(date), \(isPaywall), \"\(apisUsed)\", \(recType), \(key)  },")
}

func deriveSource(url: String) -> (String, String) {
    
    var source = "n/a"
    var githubName = ""
    var F:[String] // Translated from Perl?
    let F0 = url.components(separatedBy: "//")
    let url0:String = F0[1]
    F = url0.components(separatedBy: "/")
    if url.contains("github.com") {
        source = "github.com/" + F[1]
        // githubName = url0.stringByReplacingOccurrencesOfString("github.com/", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        githubName = F.last!
        if githubName == "README.md" {
            githubName = ""
        }
    } else if url.hasPrefix("http") { //(url =~ m#^http://([a-zA-Z0-9.\-\!\#]*)/#) {
        
        source = F[0].replacingOccurrences(of: "www.", with: "", options: NSString.CompareOptions.literal, range: nil) //  source =~ s/www[.]//;
    } else {
        source = url
        //    source =~ s/http:\/\///;
        //    my @F = split(/\//, url);
        
        //    # my @F = split(source,'/');
        source = F[0]
    }
    return (source, githubName)
}

func checkUrlImportFile(existingUrls:[String:Int]) {

	let path = "foobar.txt"
                    print("BOOOM!!!")
    if let fileManager =  FileManager.default as FileManager! {
 _ = try? fileManager.createDirectoryAtPath( path,
                   withIntermediateDirectories: true,
                                    attributes: nil )
}

	let importUrls = readLines(filePath: "/tmp/import_urls.txt")
	for url in importUrls {

                    print("NEW??: \(url)")
                if let _ = existingUrls[url] {
//                    print("Error: Duplicate URL: \(url)")
                } else {
                    print("NEW: \(url)")
		}
		
	}

}

let lines = readLines(filePath: "/tmp/swift_urls.tsv")

var allUrls:[String:Int] = [:]

var ok:Int
var i=1
for line in lines {
    //    ok = false
    if !(line.hasPrefix("#") || line.hasPrefix(" ")) {
        let aLine = line.components(separatedBy: "\t")
        if aLine.count > 1 {
            
            if let groupNum = groupNumbers[aLine[0]] {
                let url = aLine[1]
                var (source, githubName) = deriveSource(url: url)
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
                
                if isPaywall == nil {
                    isPaywall = 0
                }
                
                let apisUsed = aLine[7]
                
                var recType:Int? = Int(aLine[8])
                
                if recType == nil {
                    recType = 0
                }
                
                var recordKey:Int? = Int(aLine[9])
                
                if recordKey == nil {
                    recordKey = 0
                }
                
                let rec = UrlRecord(id: i, groupNum: groupNum, source: source, url: url, title: title, githubName: githubName, tags: tags, image: image, date: date!, isPaywall: isPaywall!, apisUsed: apisUsed, recType: recType!, key:recordKey!)
                database.append(rec)
                
                
            } else {
                print("Error: Invalid Group: \(line)")
            }
        } else {
            //            print("Error: Not enough values on line: \(line)")
        }
    }
    i += 1
}

checkUrlImportFile(existingUrls: allUrls)

func printTagsArray() {
    
    let names = allTags.keys.sorted( by: { $0.lowercased() < $1.lowercased() } )
    
    let varName = "var tagNameList = []string{"
    
    print("\(varName)")
    for name in names {
        print("\"\(name)\",", terminator:" ")
    }
    print("}")
    
}

func printTagCountVar() {
    print("var tagCountDict = map[string]int{")
    for (key, value) in allTags.sorted(by: { $0.0.lowercased() < $1.0.lowercased() }) {
        //    let count = allTags[t]
        print("\"\(key)\": \(value),")
    }
    print("}")
}

database.sort(by: { (rec1, rec2) -> Bool in
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
    
    let tagList = row.tags.components(separatedBy: ":")
    for tag in tagList {
        if tag != "" {
            if let x = allTags[tag] {
                allTags[tag] = x + 1
            } else {
                allTags[tag] = 1
            }
        }
    }
    
    writeGoVar(groupNum: row.groupNum, url:row.url, name:row.title, source:row.source, githubName: row.githubName, tags:row.tags,
               image:row.image, date:row.date,
               isPaywall:row.isPaywall,
               apisUsed: row.apisUsed,
               recType: row.recType,
               key: row.key)
}
print("}")

printTagsArray()
printTagCountVar()


