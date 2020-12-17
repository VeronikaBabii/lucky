//
//  NewLogic.swift
//  LuckyQuiz
//
//  Created by Mark Vais on 11.11.2020.
//  Copyright © 2020 Mark Vais. All rights reserved.
//

import Foundation

class NewLogic {
    
    var media_sources = [MediaSources]()
    var organic: OrganicData?
    var whatToShow: (deeplink: String, naming: String)?
    
    //MARK: - parse jsonData from checker api
    func getDataFromChecker (url: URL, completion: @escaping (Responce?) -> Void) {
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            
            guard let jsonData = data else {
                print("Error getting jsonData")
                completion(nil)
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(Responce.self, from: jsonData)
                completion(decodedData)
            }
            catch {
                print(error)
                completion(nil)
            }
        }.resume()
    }
    
    func checkerDataUsage(completion: @escaping (String) -> ()) {
        
        //let url = URL(string: "https://integr-testing.site/checker/?token=\(Consts.CLOAK_TOKEN)")!
        let url = URL(string: "https://integr-testing.site/apps_v2/checker/?bundle=com.gb.luckyquiz")!
        
        getDataFromChecker(url: url) { result in
            
            guard let res = result else {
                print("Cloak result is nil")
                return
            }
            
            let status = res.user
            
            let mediaSources = (res.media_sources)
            self.media_sources = mediaSources
            
            let organicData = res.organic
            self.organic = organicData
            
            let toShow: (String, String) = (res.deeplink, res.naming)
            self.whatToShow = toShow
            
            completion(status)
        }
    }
    
    //MARK: - deeplink/naming/organic logic
    
    func requestData() {
        
        // 1 - make cloak request
        checkerDataUsage() { [self] status in
            
            print("\nUser - \(status)\n")
            
            // 2 - check user from cloak (true - show web, false - show game) // for game testing
            if status != "true" {
                UserDefaults.standard.set("false", forKey: "SHOW_WEB")
                print("User not true - showing game")
                return
            }
            
            UserDefaults.standard.set("true", forKey: "SHOW_WEB")
            print("User true - showing web")
            
            // 3 - user == "true" - check deeplink
            let deep = "\(UserDefaults.standard.object(forKey: "deeplink") ?? "")"
            
            DeeplinkParser().getDataFromDeeplink(deeplink: deep) { deeplinkData -> () in
                
                if deeplinkData != nil && whatToShow?.deeplink == "true" { // check value of deeplink in cloak
                    print("Deeplink data - \(deeplinkData!)")
                    formLinkFromResult(deeplinkData!, status)
                    return
                }
                
                // 4 - no deeplink - check naming
                NamingParser().getDataFromNaming(mediaSources: media_sources) { namingData -> () in
                    
                    if namingData != nil && whatToShow?.naming == "true" { // check value of naming in cloak
                        print("Naming data - \(namingData!)")
                        formLinkFromResult(namingData!, status)
                        return
                    }
                    
                    // 5 - no naming - create organic
                    
                    let key = self.organic?.org_key ?? "oswn6tvtmztmokzwovqc"
                    let sub1 = self.organic?.sub1 ?? "none"
                    let sub2 = self.organic?.sub2 ?? "none"
                    let sub3 = self.organic?.sub3 ?? "none"
                    
                    let organicData = ResultData(key: key, sub1: sub1, sub2: sub2, sub3: sub3)
                    print("Organic data - \(organicData)")
                    formLinkFromResult(organicData, status)
                }
            }
        }
    }
    
    func formLinkFromResult(_ data: ResultData, _ status: String) {
        
        // create link from passed params
        var link = "https://egame.site/click.php"
        
        // neccessary params
        let key = data.key
        link.append("?key=\(key)")
        print(link)
        
        let sub1 = data.sub1
        link.append("&sub1=\(sub1)")
        print(link)
        
        // optional params
        if data.sub2 != nil && data.sub2 != "" {
            let sub2 = data.sub2
            link.append("&sub2=\(sub2!)")
            print(link)
        }
        
        if data.sub3 != nil && data.sub3 != "" {
            let sub3 = data.sub3
            link.append("&sub3=\(sub3!)")
            print(link)
        }
        
        let urlToShow = link
        UserDefaults.standard.set(urlToShow, forKey: "AGREEMENT_URL")
    }
}
