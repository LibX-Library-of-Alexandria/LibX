//
//  PreviewViewController.swift
//  Pods
//
//  Created by Mina Kim on 12/12/20.
//

import UIKit
import WebKit

class PreviewViewController: UIViewController, WKUIDelegate {

    var webView = WKWebView()
    
    var item : [String:Any]!
    var type : String!
    var id : String!
    
    var videos = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView

        //Checks type of id (String or Int)
        if ((item["id"] as? Int) != nil) {
            id = String(item["id"] as! Int)
        } else {
            id = item["id"] as! String
        }
        
        if (type == "movie" || type == "show") {
            setTrailer()
        } else {
            setEbook()
        }
    }
    
    func setTrailer() {
        let urlString = "https://api.themoviedb.org/3/tv/" + id + "/videos?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"
                let url = URL(string: urlString)!
                let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
                let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
                let task = session.dataTask(with: request) { (data, response, error) in
                   // This will run when the network request returns
                   if let error = error {
                      print(error.localizedDescription)
                   } else if let data = data {
                      let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    
                    self.videos = dataDictionary["results"] as! [[String:Any]]
                                        
                    //Retrieves key for video
                    let video_key = self.videos.first?["key"] as! String
                    print(video_key)
                    
                    //URL for video
                    let urlString = "https://www.youtube.com/watch?v=" + video_key as! String
                    let myURL = URL(string: urlString)
                    let myRequest = URLRequest(url: myURL!)
                    self.webView.load(myRequest)
                   }
                }
                task.resume()
    }
    func setEbook() {
        let bookInfo = item["volumeInfo"] as! [String:Any]
        let urlString = bookInfo["previewLink"] as! String
        let url = URL(string: urlString)
        let request = URLRequest(url: url!)
        self.webView.load(request)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
