//
//  Utils.swift
//  LuckyQuiz
//
//  Created by Mark Vais on 21.12.2020.
//  Copyright © 2020 Mark Vais. All rights reserved.
//

import Foundation

// MARK: - structs

struct Storyboard {
    static let gameViewController = "gameVC"
    static let quizViewController = "quizVC"
    static let winViewController = "winVC"
}

struct Consts {
    static let ORGANIC_FB    = "oswn6tvtmztmokzwovqc"
    static let ORGANIC_INAPP = "sl4nk4g3x0y8l6f8kiid"
    
    static let APPLE_APP_ID = "1536002227"
    static let FB_APP_ID    = "354340085862913"
    static let ONESIGNAL_ID = "a7e60277-d981-4310-82f1-e790e23777a4"
    
    static let APPSFLYER_DEV_KEY = "Yd8HTCGPw8b4VDeBvrNqtd"
    
    static let METRICA_SDK_KEY      = "7b9a2df8-dcef-47f6-b78a-abfc0b3c5b68"
    static let METRICA_POST_API_KEY = "bb299571-92d7-4e90-a7e9-c30742d99d35"
    static let METRICA_APP_ID       = "3758374"
}

// for cloak responce parsing
struct Responce: Decodable {
    var naming: String
    var deeplink: String
    var integration_version: String
    var organic: OrganicData
    var user: String
    var media_sources: [MediaSources]
}

struct OrganicData: Decodable {
    var org_status: String
    var org_key: String?
    var sub1: String?
    var sub2: String?
    var sub3: String?
}

struct MediaSources: Decodable {
    var source: String?
    var media_source: String
    var key: MediaSource
    var sub1: MediaSource
    var sub2: MediaSource
    var sub3: MediaSource
}

struct MediaSource: Decodable {
    var name: String
    var split: Bool
    var delimiter: String?
    var position: Int?
}

// for Deeplink/Naming/Organic result data
struct ResultData {
    var key: String
    var sub1: String
    var sub2: String?
    var sub3: String?
    var source: String
}

// MARK: - methods
class Utils {
    
    // send link to server
    func sendToServer(_ postString: String) {
        
        let urlStr = "https://tbraza.club/api/install_logs/create?conversionData=naming&appName=com.gb.luckyquizz&version=1"
        
        let url = URL(string: urlStr)
        guard let requestUrl = url else {
            print("Error: bad url")
            return
        }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print("Error posting data:\n \(error)")
                return
            }
            
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("\nResponse data string: \(dataString)\n")
            }
            
        }.resume()
    }
    
    //MARK: - naming
    func getDataFromNaming(mediaSources: [MediaSources], completion: (ResultData?) -> ()) {
        
        // get naming from appsflyer
        //        guard let namingDict: [String: Any] = UserDefaults.standard.object(forKey: "namingDataDict") as? [String : Any]
        //        else {
        //            print("namingDict is empty (cannot convert)")
        //            completion(nil)
        //            return
        //        }
        //        print(namingDict)
        
        // for naming testing
        let namingDict: [String: Any] = ["retargeting_conversion_type":"none",
                                         "orig_cost":"0.9",
                                         "af_ip":"85.26.241.188",
                                         "af_cost_currency":"USD",
                                         "is_first_launch":true,
                                         "af_click_lookback":"7d",
                                         "iscache":true,
                                         "click_time":"2020-12-12 17:13:41.728",
                                         "match_type":"id_matching",
                                         "campaign_id":"5fd4f0baebb932a5c6f71839",
                                         "game_id":"500057978",
                                         "install_time":"2020-12-13 09:54:39.922",
                                         "redirect":"false",
                                         "gamer_id":"580793b140edac597396b80755a2365928ce1a45e2df0dbfee59c3d97492f544590702c6fc68322704cf4d190e04bc54941fc9612adba2f6007b0e600ac7ae67c97f53a26837a127260fd500a1eebdfda01faadf65f580e3a9c47b0a",
                                         "af_ua":"Mozilla/5.0 (Linux; Android 10; SM-A115F Build/QP1A.190711.020; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/81.0.4044.138 Mobile Safari/537.36",
                                         "af_c_id":"5fd4f0baebb932a5c6f71839",
                                         "media_source":"unityads_int",
                                         "idfa":"8525ab92-ec44-449b-8703-ac118ad45000",
                                         "advertising_id":"8525ab92-ec44-449b-8703-ac118ad45000",
                                         "af_siteid":"26c1XQkGCQAO",
                                         "af_status":"Non-organic",
                                         "cost_cents_USD":"90",
                                         "af_ad_id":"5fd4f133f121c82dd9298da3",
                                         "af_adset":"kreo4",
                                         "af_cost_value":"0.90",
                                         "campaign":"6pts2sibb2tnag58yvg9:yaroslavFrootGardenRu",
                                         "af_cost_model":"cpi",
                                         "af_ad":"kreo4"
        ]
        
        var key = ""
        var sub1 = ""
        var sub2 = ""
        var sub3 = ""
        var src = ""
        
        var isOneMediaPresent = false
        
        // check wheter naming source is the same to one of sources in cloak media_sources
        for source in mediaSources {
            
            // naming source is the same as cloak source - there is naming
            if source.media_source == namingDict["media_source"] as? String {
                print(source.media_source)
                isOneMediaPresent = true
                
                key = getNamingParamData(of: source.key, at: namingDict)
                sub1 = getNamingParamData(of: source.sub1, at: namingDict)
                sub2 = getNamingParamData(of: source.sub2, at: namingDict)
                sub3 = getNamingParamData(of: source.sub3, at: namingDict)
                src = source.source ?? "none"
                
                let namingData = ResultData(
                    key: key,
                    sub1: sub1,
                    sub2: sub2,
                    sub3: sub3,
                    source: src)
                
                completion(namingData)
            }
        }
        
        // naming source is different from cloak source - no naming
        if !isOneMediaPresent {
            print("Empty naming - going further")
            completion(nil)
        }
    }
    
    func getNamingParamData(of ss: MediaSource, at namingDict: [String:Any]) -> String {
        
        // let ss = source.key or source.sub1 ..
        var res = ""
        
        if ss.split == true {
            let cloakName = ss.name
            let namingName = namingDict[cloakName] as? String ?? "none"
            
            let splitBy = ss.delimiter ?? "" // if we have a split, so that del and pos
            let pos = ss.position ?? 0
            
            let splited = namingName.components(separatedBy: splitBy)
            let elem: String = splited[pos]
            res = elem
            
        } else {
            let cloakName = ss.name
            res = namingDict[cloakName] as? String ?? "none"
        }
        return res
    }
    
    //MARK: - deeplink
    struct InnerAppLinkData: Decodable {
        var target_url: String
        var extras: Extras
    }
    
    struct Extras: Decodable {
        var key: String
        var sub1: String
        var sub2: String?
        var sub3: String?
    }
    
    // 1 - get deeplink and form jsonStr from in
    func formJsonStr(deeplink: String) -> String {
        
        // 1 - split deeplink by al_applink_data=
        let outerApplink = deeplink.components(separatedBy: "al_applink_data=")[1]
        
        // 2 - decode
        let decodedApplink = outerApplink.removingPercentEncoding!
        
        // 3 - split by al_applink_data=
        let innerApplink = decodedApplink.components(separatedBy: "al_applink_data=")[1]
        
        // 4 - get rid of unneeded extras part
        let withoutExtras = innerApplink.components(separatedBy: "\",\"")[0]
        
        // 6 - get rid of \
        let withoutBadSymbols = withoutExtras.replacingOccurrences(of: "\\", with: "")
        
        return withoutBadSymbols
    }
    
    // 2 - jsonStr to Json and then decode via structs
    func parseJSON(jsonString: String, completion: @escaping (InnerAppLinkData?) -> Void) {
        
        let data = jsonString.data(using: .utf8)!
        
        do {
            let decodedData = try JSONDecoder().decode(InnerAppLinkData.self, from: data)
            print(decodedData)
            completion(decodedData)
        }
        catch {
            print(error)
            completion(nil)
        }
    }
    
    // 3 - get deeplink params from decoded Json
    func getParamsFromDeeplink(deeplink: String) -> [String: String] {
        
        let jsonStr = formJsonStr(deeplink: deeplink)
        
        var queriesDict = [String: String]()
        
        parseJSON(jsonString: jsonStr) { result in
            
            guard let result = result else {
                print("Result is empty")
                return
            }
            
            queriesDict["key"] = result.extras.key
            queriesDict["sub1"] = result.extras.sub1
            
            if result.extras.sub2 != nil {
                queriesDict["sub2"] = result.extras.sub2
            }
            
            if result.extras.sub2 != nil {
                queriesDict["sub3"] = result.extras.sub3
            }
        }
        return queriesDict
    }
    
    // NewLogic helper
    func getDataFromDeeplink(deeplink: String, completion: (ResultData?) -> ()) {
        
        if deeplink == "" {
            print("No deeplink - going further")
            completion(nil)
            return
        }
        
        let queries = getParamsFromDeeplink(deeplink: deeplink)
        print("Deeplink queries are \(queries)")
        
        let deeplinkData = ResultData(
            key: queries["key"] ?? "",
            sub1: queries["sub1"] ?? "",
            sub2: queries["sub2"] ?? nil,
            sub3: queries["sub3"] ?? nil,
            source: "fb")
        
        completion(deeplinkData)
    }
}
