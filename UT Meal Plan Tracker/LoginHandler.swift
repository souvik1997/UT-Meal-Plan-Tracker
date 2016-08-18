//
//  LoginHandler.swift
//  UT Meal Plan Tracker
//
//  Created by Souvik Banerjee on 8/17/16.
//  Copyright © 2016 Souvik Banerjee. All rights reserved.
//

import Foundation
import Fuzi


class LoginHandler: NSObject{

    var eid: String
    var password: String

    init(eid: String, password: String) {
        self.eid = eid
        self.password = password
        super.init()
    }

    func urlencode(string: String) -> String {
        return string.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
    }
    
    func authGet(url: URL, callback: @escaping (Bool, String) -> Void) {
        func route(data: Data?, response: URLResponse?, error: Error?) {
            let htmlResponse = String(data: data!, encoding: String.Encoding.utf8)
            if (htmlResponse?.contains("UT EID Login"))! {
                submitCredentials()
            } else if (htmlResponse?.contains("Submit LARES data"))! {
                do {
                    let document = try HTMLDocument(string: htmlResponse!)
                    let matchedElements = document.xpath("/html/body/form/input")
                    if (matchedElements.count == 0) {
                        callback(false, htmlResponse!)
                    }
                    submitLARESData(data: matchedElements.first!["value"]!)
                } catch let error {
                    print(error)
                    callback(false, htmlResponse!)
                }
            } else if (response?.url == url) {
                callback(true, htmlResponse!)
            } else if (htmlResponse?.contains("<META HTTP-EQUIV=\"Refresh\" CONTENT=\"0; URL=utdirect/index.WBX\">"))! {
                URLSession.shared.dataTask(with: url) { (data, response, error) in route(data: data, response: response, error: error)
                }.resume()
            } else if (htmlResponse?.contains("Invalid UTLogin Credentials"))! {
                callback(false, htmlResponse!)
            } else {
                callback(false, htmlResponse != nil ? htmlResponse! : "")
            }
        }
        
        func submitCredentials() {
            var urlReq = URLRequest(url: URL(string: "https://login.utexas.edu/login/UI/Login")!)
            urlReq.httpMethod = "POST"
            let loginStr = "IDToken1=\(self.eid)&IDToken2=\(self.password)&login_uri=/login/cdcservlet&login_method=GET&IDButton=Log In&goto=\(url.absoluteURL)&encoded=false&gx_charset=UTF-8"
            print("loginStr " + loginStr)
            urlReq.httpBody = loginStr.data(using: String.Encoding.utf8)
            URLSession.shared.dataTask(with: urlReq) {(data, response, error) in route(data: data, response: response, error: error) }.resume()
        }
        
        func submitLARESData(data: String) {
            var urlReq = URLRequest(url: URL(string: "https://utdirect.utexas.edu:443/")!)
            urlReq.httpMethod = "POST"
            let escapedStr = "LARES="+self.urlencode(string: "\(data)")
            print(escapedStr)
            urlReq.httpBody = escapedStr.data(using: String.Encoding.utf8)
            URLSession.shared.dataTask(with: urlReq) {(data, response, error) in route(data: data, response: response, error: error) }.resume()
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in route(data: data, response: response, error: error)
        }.resume()
        
    }
}