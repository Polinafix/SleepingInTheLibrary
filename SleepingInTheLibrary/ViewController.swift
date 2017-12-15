//
//  ViewController.swift
//  SleepingInTheLibrary
//
//  Created by Polina Fiksson
//

import UIKit

// MARK: - ViewController: UIViewController

class ViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoTitleLabel: UILabel!
    @IBOutlet weak var grabImageButton: UIButton!
    
    // MARK: Actions
    
    @IBAction func grabNewImage(_ sender: AnyObject) {
        setUIEnabled(false)
        getImageFromFlickr()
    }
    
    // MARK: Configure UI
    
    private func setUIEnabled(_ enabled: Bool) {
        photoTitleLabel.isEnabled = enabled
        grabImageButton.isEnabled = enabled
        
        if enabled {
            grabImageButton.alpha = 1.0
        } else {
            grabImageButton.alpha = 0.5
        }
    }
    
    // MARK: Make Network Request
    
    private func getImageFromFlickr() {
        
        // TODO: Write the network code here!
        
        let myParams = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.GalleryPhotosMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.GalleryID: Constants.FlickrParameterValues.GalleryID,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
            ]
        
        let fullUrl = Constants.Flickr.APIBaseURL + escapedParameters(myParams as [String:AnyObject])
        let url = URL(string: fullUrl)
        //wrap url with the URLRequest > it has more functionality
        let request = URLRequest(url: url!)
        
        
        //Get a shared URLSession instance, which uses the default configuration
        let session = URLSession.shared
        
        //3.Create a data task. =
        let task = session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                
                
                /* GUARD: Did we get a successful 2XX response? */
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                    print("Your request returned a status code other than 2xx!")
                    return
                }
               // Get the raw JSON data (data)
                if let data = data {
                    let parsedResult: [String:Any]!
                    //convert stream of bytes of JSON data into a Foundation object(array or dictionary)
                    do {
                        parsedResult = try JSONSerialization.jsonObject(with: data, options:[]) as! [String:Any]
                    }catch {
                        print("Could not parse the data as JSON: '\(data)'")
                        return
                    }
                    
                   // print(parsedResult)
                    
                    //Grab the data from the Foundation object and use it
                    
                    if let photosDictionary = parsedResult["photos"] as? [String:Any], let photoArray = photosDictionary["photo"] as? [[String:AnyObject]] {
                       // print(photoArray[0])
                        let randomIndex = Int(arc4random_uniform(UInt32(photoArray.count)))
                        let randomPhotoDict = photoArray[randomIndex]
                        if let photoTitle  = randomPhotoDict["title"] as? String,
                            let photoUrlString = randomPhotoDict["url_m"] as? String{
                            //print("The title is: \(photoTitle)")
                            // print("The url is: \(photoUrl)")
                            //create the url for the image
                            let imageURL = URL(string: photoUrlString)
                            //create image data from the url:
                            if let imageData = try? Data(contentsOf:imageURL!){
                                DispatchQueue.main.async {
                                    //create the image from this data
                                    self.photoImageView.image = UIImage(data: imageData)
                                    self.photoTitleLabel.text = photoTitle
                                    //reenable the UI
                                    self.setUIEnabled(true)
                                }
                               
                            }
                        }
                        
                    }
                    
                   
                }
                
                
            }
        }
        task.resume()
        
        
        
            //print(url)
    }
    
    private func escapedParameters(_ params: [String: AnyObject]) -> String {
        if params.isEmpty {
            return ""
        }else {
            var newParams = [String]()
            
            for (key,value) in params {
               //make sure that this is a string
                let stringValue = "\(value)"
                //escape the value
                let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                let newParam = key + "=" + "\(escapedValue!)"
                newParams.append(newParam)
                
            }
            
            return "?\(newParams.joined(separator: "&"))"
            
            
        }
    }
}
