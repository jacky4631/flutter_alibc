//
//  AlibcUltimateWkWebView.swift
//  flutter_alibc_ultimate
//

import Foundation
import WebKit

protocol AlibcUltimateWkWebViewDelegate : NSObject {
    func noticeToken(result:String)
    func noticeCode(result:String)
}

class AlibcUltimateWkWebView: UIViewController{
    var fuctionType:String!
    var openUrl:String?
    var webview : WKWebView!
    var delegate: AlibcUltimateWkWebViewDelegate?

    init() {
        super.init(nibName: nil, bundle: nil)
        WVURLProtocolService.setSupportWKURLProtocol(true)
        self.webview = WKWebView.init(frame: view.frame)
        self.webview.autoresizingMask = [.flexibleWidth , .flexibleHeight]
        self.webview.scrollView.isScrollEnabled = true;
        self.webview.navigationDelegate = self
        self.view.addSubview(webview)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "淘你喜欢"
        let doneBtn = UIButton(type: UIButton.ButtonType.system)
        doneBtn.setTitle("关闭", for: UIControl.State.normal)
        doneBtn.addTarget(self, action: #selector(doneBtnAction), for: UIControl.Event.touchUpInside)
        self.navigationItem.rightBarButtonItem =  UIBarButtonItem(customView: doneBtn)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView:doneBtn);
    }

    public func getWebView() -> WKWebView{
        return webview
    }

    @objc private func doneBtnAction (){
        self.navigationController?.dismiss(animated: true, completion: {
            if self.fuctionType == "token" {
                self.delegate?.noticeToken(result: "")
            }else {
                self.delegate?.noticeCode(result: "")
            }
        })
    }
}

extension AlibcUltimateWkWebView : WKNavigationDelegate{
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(WKNavigationActionPolicy.allow)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("页面开始加载")
    }

    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("重定向")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print(webview.url?.absoluteString as Any)
        let urlStr = webview.url?.absoluteString
        var range: NSRange
        var rangeCode : NSRange
        range = (urlStr! as NSString).range(of: "access_token")
        rangeCode = (urlStr! as NSString).range(of: "code=")
        if range.location != NSNotFound {
            let accessString = (urlStr! as NSString).substring(from: range.location)
            let range2 = (accessString as NSString).range(of: "&")
            let access_token_string = (accessString as NSString).substring(with: NSRange(location: 0, length: range2.location))
            self.navigationController?.dismiss(animated: true, completion: {
                self.delegate?.noticeToken(result: access_token_string)
            })
        }else if rangeCode.location != NSNotFound {
            var dic = [String:String]()
            let arr = urlStr!.components(separatedBy:"&")
            for item in arr {
                    let arr2 = item.components(separatedBy:"=")
                    let key = arr2[0]
                    let val = arr2[1]
                    dic[key] = val
            }
            let codeString = "code=" + dic["code"]!
            self.navigationController?.dismiss(animated: true, completion: {
                self.delegate?.noticeCode(result: codeString)
            })
        }
    }

    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let card = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(URLSession.AuthChallengeDisposition.useCredential,card)
        }
    }
}

extension AlibcUltimateWkWebView : WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {}
}
