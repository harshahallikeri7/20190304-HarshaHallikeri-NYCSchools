//
//  DetailViewController.swift
//  20190304-HarshaHallikeri-NYCSchools
//
//  Created by Harsha Hallikeri on 3/4/19.
//  Copyright © 2019 Harsha Hallikeri. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    //Dictionary used to store SAT score vales
    var schoolDetails:Dictionary< String, String > = Dictionary< String, String >()

    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var mathScoreLabel: UILabel!
    @IBOutlet weak var readingScoreLabel: UILabel!
    @IBOutlet weak var writingScoreLabel: UILabel!
    @IBOutlet weak var noResultsLabel: UILabel!
    @IBOutlet weak var scoreView: UIView!
   
    var toPass:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noResultsLabel.isHidden = true
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {

        get_data_from_url("https://data.cityofnewyork.us/resource/f9bf-2cp4.json")
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //If more time its good to use Generic class for calling all APIs from single function.
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
                    if let dbn = school_obj["dbn"] as? String
                    {
                        if dbn == toPass{
                            
                            schoolDetails.updateValue((school_obj["school_name"] as? String)! , forKey:"schoolname" )
                            
                            schoolDetails.updateValue((school_obj["sat_math_avg_score"] as? String)! , forKey:"mathScore" )
                            schoolDetails.updateValue((school_obj["sat_critical_reading_avg_score"] as? String)! , forKey:"readingScore" )
                            schoolDetails.updateValue((school_obj["sat_writing_avg_score"] as? String)! , forKey:"writingScore" )
                            
                        }
                    }
                }
            }
        }
       DispatchQueue.main.async(execute: {self.updateValues()})
    }

    func updateValues()
    {
        if schoolDetails.count == 0{
            self.noResultsLabel.isHidden = false
            self.scoreView.isHidden = true
        }else{
            self.noResultsLabel.isHidden = true
            self.scoreView.isHidden = false
            self.schoolNameLabel.text = self.schoolDetails["schoolname"]
            self.mathScoreLabel.text = self.schoolDetails["mathScore"]
            self.readingScoreLabel.text = self.schoolDetails["readingScore"]
            self.writingScoreLabel.text = self.schoolDetails["writingScore"]
        }
    }
    
    @IBAction func DismissView(sender: AnyObject){
        self.dismiss(animated: false, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
