//
//  TrendsViewController.swift
//  UpHoldMobile
//
//  Created by Adam Ding on 7/23/19.
//  Copyright © 2019 Shannon Ferguson. All rights reserved.
//

import UIKit
import AVKit


class TrendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var result = Response()
    
    let slp = SwiftLinkPreview(cache: InMemoryCache())
    

    var tempImage = Response()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.trendTableView.rowHeight = self.trendTableView.frame.height / 4
    }
    
    var clientTrends = [TrendsModel]()
    var trendIndex: Int!
    @IBOutlet weak var trendTableView: UITableView! {
        didSet {
            self.trendTableView.dataSource = self
            self.trendTableView.delegate = self
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clientTrends.count   //currently number is huge. 600 < count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = trendTableView.dequeueReusableCell(withIdentifier: "TrendCell") as! TrendCell
        let currentTrend = clientTrends[indexPath.row]
        cell.trendTopicLabel.text = currentTrend.title!
        cell.trendDateLabel.text = getDate(myDate: currentTrend.time_published!)
        cell.clientTrends = self.clientTrends
        cell.clientIndex = indexPath.row
        trendIndex = indexPath.row
       
        slp.preview(clientTrends[indexPath.row].url!,
                    onSuccess: { result in
                        //print("Success " + "\(result)")
                        let image_path = result.image ?? "ft"
                        let catPictureURL = URL(string: image_path)!
                        
                        
                        let session = URLSession(configuration: .default)
                        
                        let downloadPicTask = session.dataTask(with: catPictureURL) { (data, response, error) in
                            // The download has finished.
                            if let e = error {
                                print("Error downloading cat picture: \(e)")
                            } else {
                                // No errors found.
                                // It would be weird if we didn't have a response, so check for that too.
                                if let res = response as? HTTPURLResponse {
                                    if let imageData = data {
                                            let image = UIImage(data: imageData)
                                            //cell.trendImage.image = image
                                    } else {
                                        print("Couldn't get image: Image is nil")
                                    }
                                } else {
                                    print("Couldn't get response code for some reason")
                                }
                            }
                        }
                        
                        
                        downloadPicTask.resume()
        },
                    onError: { error in print("Failure " + "\(error)")})

        return cell
    }
    
   
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //Segues into ClientSummaryViewController
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "trendToWeb", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //segues information into ClientSummaryViewController
        let vc = segue.destination as! ClientsWebViewController
        vc.trendsIndex = trendIndex
        vc.allTrends = self.clientTrends
    }
    
    func getDate(myDate: String) -> String {
        var index = myDate.index(myDate.startIndex, offsetBy: 10)
        let date = myDate[..<index]
        return String(date)
    }
}
