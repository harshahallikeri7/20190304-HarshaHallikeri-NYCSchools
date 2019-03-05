//
//  TableViewController.swift
//  20190304-HarshaHallikeri-NYCSchools
//
//  Created by Harsha Hallikeri on 3/4/19.
//  Copyright © 2019 Harsha Hallikeri. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    var schoolArray = [Dictionary<String, String>]()
    var TableData:Dictionary< String, String > = Dictionary < String, String >()
    var selectedResult:String?
    var dbnnumber:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        get_data_from_url("https://data.cityofnewyork.us/resource/s3k6-pzi2.json")
    }
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schoolArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let dict = schoolArray[indexPath.row]
        cell.textLabel?.text = dict["name"]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = schoolArray[indexPath.row]
        dbnnumber = dict["dbn"]
        performSegue(withIdentifier: "DetailView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if(segue.identifier == "DetailView") {

            let svc = segue.destination as! DetailViewController
            svc.toPass = dbnnumber

        }

    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    func get_data_from_url(_ link:String)
    {
        let url:URL = URL(string: link)!
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (
            data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                
                return
            }
           self.extract_json(data!)
        })
        
        task.resume()
        
    }
    
    
    func extract_json(_ data: Data)
    {
        let json: Any?
        
        do
        {
            json = try JSONSerialization.jsonObject(with: data, options: [])
        }
        catch
        {
            return
        }
        
        guard let data_list = json as? NSArray else
        {
            return
        }
        
        if let schools_list = json as? NSArray
        {
            for i in 0 ..< data_list.count
            {
                if let school_obj = schools_list[i] as? NSDictionary
                {
                    if (school_obj["school_name"] as? String) != nil
                    {
                        TableData.updateValue((school_obj["school_name"] as? String)!, forKey: "name")
                        TableData.updateValue((school_obj["dbn"] as? String)!, forKey: "dbn")
                        schoolArray.append(TableData)
                    }
                }
            }
        }
        DispatchQueue.main.async(execute: {self.do_table_refresh()})
        
    }
    
    func do_table_refresh()
    {
        self.tableView.reloadData()
        
    }
    

}
