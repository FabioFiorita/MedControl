//
//  WebView.swift
//  MedControl
//
//  Created by Fabio Fiorita on 21/01/21.
//

import Foundation
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    
    var url: String
    
    func makeUIView(context: Context) -> WKWebView {
        guard let url = URL(string: self.url) else {
            return WKWebView()
        }
        
    let request = URLRequest(url: url)
    let wkWebView = WKWebView()
    wkWebView.load(request)
    return wkWebView
    }
    
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<WebView>) {
        
    }
}
