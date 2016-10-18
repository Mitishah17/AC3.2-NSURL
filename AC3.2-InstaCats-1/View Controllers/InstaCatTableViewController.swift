//
//  InstaCatTableViewController.swift
//  AC3.2-InstaCats-1
//
//  Created by Louis Tur on 10/10/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import UIKit

struct InstaCat {
    // add necessary ivars and initilizations; check the tests to know what you should have
    
    let name: String
    let id: Int
    let instagramURL: URL
    var description: String {
        return "Nice to meeet you, I'm \(name)"
    }
    
}

class InstaCatTableViewController: UITableViewController {
    
    internal let InstaCatTableViewCellIdentifier: String = "InstaCatCellIdentifier"
    internal let instaCatJSONFileName: String = "InstaCats.json"
    internal var instaCats: [InstaCat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let instaCatsURL: URL = self.getResourceURL(from: instaCatJSONFileName),
            let instaCatData: Data = self.getData(from: instaCatsURL),
            let instaCatsAll: [InstaCat] = self.getInstaCats(from: instaCatData) else {
                return
        }
        
        self.instaCats = instaCatsAll
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Data
    internal func getResourceURL(from fileName: String) -> URL? {
        guard let dotRange = fileName.rangeOfCharacter(from: CharacterSet.init(charactersIn: ".")) else {
            return nil
        }
        
        // 2. The upperbound of a range represents the position following the last position in the range, thus we can use it
        // to effectively "skip" the "." for the extension range
        let fileNameComponent: String = fileName.substring(to: dotRange.lowerBound)
        let fileExtenstionComponent: String = fileName.substring(from: dotRange.upperBound)
        
        // 3. Here is where Bundle.main comes into play
        let fileURL: URL? = Bundle.main.url(forResource: fileNameComponent, withExtension: fileExtenstionComponent)
        
        return fileURL
    }
    
    internal func getData(from url: URL) -> Data? {
        // 1. this is a simple handling of a function that can throw. In this case, the code makes for a very short function
        // but it can be much larger if we change how we want to handle errors.
        let fileData: Data? = try? Data(contentsOf: url)
        return fileData
    }
    
    internal func getInstaCats(from jsonData: Data) -> [InstaCat]? {
        // 1. This time around we'll add a do-catch
        do {
            let instaCatJSONData: Any = try JSONSerialization.jsonObject(with: jsonData, options: [])
            
            // 2. Cast from Any into a more suitable data structure and check for the "cats" key
            
            if let instaCatDict = instaCatJSONData as? [String: [[String: String]]] {
                if let catData = instaCatDict["cats"]{
                    for cat in catData {
                        if let name = cat["name"], let id = cat["cat_id"], let instagramURL = cat["instagram"], let idInt = Int(id), let instaU = URL.init(string: instagramURL){
                            
                            let data = InstaCat.init(name: name, id: idInt, instagramURL: instaU)
                            instaCats.append(data)
                        }
                    }
                }
            }
            return instaCats
        }
            // 3. Check for keys "name", "cat_id", "instagram", making sure to cast values as needed along the way
            
            // 4. Return something
        catch let error as NSError {
            // JSONSerialization doc specficially says an NSError is returned if JSONSerialization.jsonObject(with:options:) fails
            print("Error occurred while parsing data: \(error.localizedDescription)")
        }
        
        return  nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIApplication.shared.open(instaCats[indexPath.row].instagramURL)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instaCats.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InstaCatCellIdentifier", for: indexPath)
        
        let cat = instaCats[indexPath.row]
        
        cell.textLabel?.text = cat.name
        cell.detailTextLabel?.text = cat.description
        
        return cell
    }
}






