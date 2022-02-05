//
//  UnitConverter.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import SwiftUI
import UIKit
import CryptoKit
import AudioToolbox

extension UIDevice {
    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}

extension Double {
    func toInt() -> Int {
        if self >= Double(Int.min) && self < Double(Int.max) {
            return Int(self)
        } else {
            return 0
        }
    }
    
    func secToMinString(_ div:String = ":") -> String {
        let sec = self.toInt() % 60
        let min = floor( Double(self / 60) ).toInt()
        return min.description.toFixLength(2) + div + sec.description.toFixLength(2)
    }
    func secToHourString(_ div:String = ":") -> String {
        let sec = self.toInt() % 60
        let min = floor( Double(self / 60) ).toInt() % 60
        let hour = floor( Double(self / 3600) ).toInt()
        return hour.description.toFixLength(2) + div + min.description.toFixLength(2) + div + sec.description.toFixLength(2)
    }
    
    func millisecToSec() -> Double {
        return self/1000.0
    }
    
    func toPercent(n:Int = 0) -> String {
        return self.toTruncateDecimal(n:n) + "%"
    }
    
    func toTruncateDecimal (n:Int = 0) -> String {
        return String(format: "%." + n.description + "f", self)
    }
    func sinceNow()->String {
        let now = Date(timeIntervalSinceNow: 0).localDate()
        let diff = (now.currentTimeMillis() - self)
        DataLog.d(Date().currentTimeMillis().description)
        DataLog.d(self.description)
        return diff.since()
    }
    
    func since()->String {
    
        var value:Double = 0
        var unit:String = ""
       
        if self < 60 * 1000 {
            return "now"
        }
        else if self < 60 * 1000 * 60 {
            value = self / (60 * 1000)
            unit = "min"
        }
        else if self < 60 * 1000 * 60 * 24 {
            value = self / ( 60 * 1000 * 60)
            unit = "hour"
        }
        else if self < 60 * 1000 * 60 * 24 * 30{
            value = self / ( 60 * 1000 * 60 * 24)
            unit = "day"
        }
        else if self < 60 * 1000 * 60 * 24 * 365 {
            value = self / ( 60 * 1000 * 60 * 24 * 30)
            unit = "month"
        }
        else {
            value = self / ( 60 * 1000 * 60 * 24 * 365)
            unit = "year"
        }
        return String(format: "%.0f",  value ) + unit
    }
}


extension Date{
    func localDate() -> Date {
        let nowUTC = Date()
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: nowUTC))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: nowUTC) else {return Date()}
        return localDate
    }
    func currentTimeMillis() -> Double {
        return Double(self.timeIntervalSince1970 * 1000)
    }
    
    func toDateFormatter(dateFormat:String = "yyyy-MM-dd'T'HH:mm:ssZ",
                     local:String="en_US_POSIX") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: local) // set locale to reliable US_POSIX
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from:self)
    }
    
    func isBetween(_ date1: Date, and date2: Date) -> Bool {
        return (min(date1, date2) ... max(date1, date2)).contains(self)
    }
    
    func getDDay() -> Int {
        Int(ceil(self.timeIntervalSince(AppUtil.networkTimeDate()) / 24)) - 1
    }
    
    func getWeekday()-> Int {
        return Calendar.current.component(.weekday, from: self)
    }
}

extension CryptoKit.SHA256.Digest {
    var bytes: [UInt8] { Array(makeIterator()) }
    var data: Data { Data(bytes) }
    var hexStr: String {
        bytes.map { String(format: "%02X", $0) }.joined()
    }
}

extension String{
    func replace(_ originalString:String, with newString:String) -> String {
        return self.replacingOccurrences(of: originalString, with: newString)
    }
    func replace(_ newString:String) -> String {
        return self.replacingOccurrences(of: "%s" , with: newString)
    }
    func replace(first:String, second:String) -> String {
        let new = self.replacingOccurrences(of: "%s1" , with: first)
        return new.replacingOccurrences(of: "%s2" , with: second)
    }
    
    func replace(start:Int, len:Int, with:String) -> String {
        let range = self.index(self.startIndex, offsetBy: start)...self.index(self.startIndex, offsetBy: start + len)
        return self.replacingCharacters(in: range, with: with)
    }
    
    func subString(_ start:Int) -> String {
        let range = self.index(self.startIndex, offsetBy: start)..<self.endIndex
        return String(self[range])
    }
    
    func subString(start:Int, len:Int) -> String {
        let range = self.index(self.startIndex, offsetBy: start)...self.index(self.startIndex, offsetBy: start + (len-1))
        return String(self[range])
    }
    
    
    func parseJson() -> [String: Any]? {
        guard let data = self.data(using: .utf8) else {
            DataLog.e("parse : jsonString data error", tag: "parseJson")
            return nil
        }
        do{
            let value = try JSONSerialization.jsonObject(with: data , options: [])
            guard let dictionary = value as? [String: Any] else {
                DataLog.e("parse : dictionary error", tag: "parseJson")
                return nil
            }
            return dictionary
        } catch {
            DataLog.e("parse : JSONSerialization " + error.localizedDescription, tag: "parseJson")
           return nil
        }
    }
    
    
    func getArrayAfterRegex(regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self,
                                        range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            DataLog.d("invalid regex: \(error.localizedDescription)", tag: "getArrayAfterRegex")
            return []
        }
    }
    
    func textHeightFrom(width: CGFloat,fontSize: CGFloat,  fontName: String = "System Font") -> CGFloat {

        #if os(macOS)
        typealias UXFont = NSFont
        let text: NSTextField = .init(string: self)
        text.font = NSFont.init(name: fontName, size: fontSize)

        #else
        typealias UXFont = UIFont
        let text: UILabel = .init()
        text.text = self
        text.numberOfLines = 0

        #endif
        text.font = UXFont.init(name: fontName, size: fontSize)
        text.lineBreakMode = .byWordWrapping
        return text.sizeThatFits(CGSize.init(width: width, height: .infinity)).height
    }
    
    func textLineNumFrom(width: CGFloat,fontSize: CGFloat,  fontName: String = "System Font") -> Int {
        #if os(macOS)
        typealias UXFont = NSFont
        let text: NSTextField = .init(string: self)
        text.font = NSFont.init(name: fontName, size: fontSize)

        #else
        typealias UXFont = UIFont
        let text: UILabel = .init()
        text.text = self
        text.numberOfLines = 0

        #endif
        text.font = UXFont.init(name: fontName, size: fontSize)
        text.lineBreakMode = .byWordWrapping
        text.sizeThatFits(CGSize.init(width: width, height: .infinity))
        return text.numberOfLines
    }
    
    func textSizeFrom(fontSize: CGFloat,  fontName: String = "System Font") -> CGSize {
        let font = UIFont.init(name: fontName, size: fontSize)
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = (self as NSString).size(withAttributes: fontAttributes as [NSAttributedString.Key : Any])
        return size
    }
    
    func underline() -> NSMutableAttributedString {
        let range = NSMakeRange(0,self.count)
        let attributedText = NSMutableAttributedString(string: self)
        attributedText.addAttribute(NSAttributedString.Key.underlineStyle , value: NSUnderlineStyle.single.rawValue, range: range)
        return attributedText
    }
    
    func toBool() -> Bool {
        if self.uppercased() == "TRUE" {return true}
        if self.uppercased() == "Y" {return true}
        if self == "1" {return true}
        return false
    }
    
    func toInt() -> Int {
        return Int(self) ?? -1
    }
    
    func toDouble() -> Double {
        return Double(self) ?? -1
    }
    
    func toUrl()-> URL? {
        let temp = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: temp)
    }
    func toColor()-> Color {
         let hex = self.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
         var int: UInt64 = 0
         Scanner(string: hex).scanHexInt64(&int)
         let a, r, g, b: UInt64
         switch hex.count {
         case 3: // RGB (12-bit)
             (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
         case 6: // RGB (24-bit)
             (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
         case 8: // ARGB (32-bit)
             (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
         default:
             (a, r, g, b) = (1, 1, 1, 0)
         }
         return Color.init(
             .sRGB,
             red: Double(r) / 255,
             green: Double(g) / 255,
             blue:  Double(b) / 255,
             opacity: Double(a) / 255
         )
     }
    
    func toFixLength(_ l:Int, prefix:String = "000000") -> String {
        if self.count >= l { return self }
        let fix:String = prefix + self
        return String(fix.suffix(l))
    }
    
    //let isoDate = "2016-04-14T10:44:00+0000"
    func toDate(
        dateFormat:String = "yyyy-MM-dd'T'HH:mm:ssZ",
        local:String="en_US_POSIX"
     ) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: local) // set locale to reliable US_POSIX
        dateFormatter.dateFormat = dateFormat
        let date = dateFormatter.date(from:self)
        return date
    }
    
    func toHMS(div:String = ":") -> String {
        if self.count <= 2 {
            return self
        } else if self.count <= 4 {
            return self.subString(start:0, len: min(2, self.count-2)) + div + self.subString(start:self.count-2, len: 2)
        } else{
            let h = self.subString(start:0, len: min(2, self.count-4))
            if h == "0" || h == "00"{
                return self.subString(start:self.count-4, len: 2 ) + div + self.subString(start:self.count-2, len: 2)
            }else{
                return h + div + self.subString(start:self.count-4, len: 2 )
                        + div + self.subString(start:self.count-2, len: 2)
            }
        }
    }
    
  
    func toSHA256() -> String {
        let inputData = Data(self.utf8)
        let hashed = CryptoKit.SHA256.hash(data: inputData)
        return hashed.hexStr
    }
    
    func toAES(key:String , iv:String, pass:String = "") -> String {
        let key = SymmetricKey(data: key.data(using: .utf8)!)
        //let ivData = Data(iv.utf8)
        let inputData = Data(self.utf8)
        let iv = AES.GCM.Nonce()
        let sealedBox = try? AES.GCM.seal(inputData, using: key, nonce: iv)
        return sealedBox?.combined?.base64EncodedString() ?? ""
    }
    
   
    
    func isEmailType() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    func isPasswordType() -> Bool {
        //let passwordRegEx = "^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8}$"
        //let predicate = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        //return predicate.evaluate(with: self)
        return self.count >= 6
    }
    
    func onlyNumric()-> String {
        let ruleNum = "[0-9]"
        return self.getArrayAfterRegex(regex: ruleNum ).reduce("", {$0 + $1})
    }
    
    func isNickNameType() -> Bool {
        let n = self.count
        if n < 1 { return false }
        if n > 8 { return false }
        /*
        let ruleNum = "[0-9]"
        let resultNum = self.getArrayAfterRegex(regex: ruleNum )
        if resultNum.count == n { return false }
    
        let rule = "[0-9가-힣a-zA-Z]"
        let result = self.getArrayAfterRegex(regex: rule )
        if result.count == n { return true}
        */
        return true
    }
    func isPhoneNumberType() -> Bool {
        if self.count < 7 { return false }
        return Int(self) != nil
    }
    func isCertificationNumberType() -> Bool {
        if self.count < 6 { return false }
        return Int(self) != nil
    }
    
    func toDecimal(divid:Double = 1 ,f:Int = 0) -> String {
        guard let num = Double(self) else { return  "0"}
        let isDecimal = num.truncatingRemainder(dividingBy: divid) == 0 ? "%.0f" : "%."+f.description+"f"
        let n = num / divid
        let s = String(format: isDecimal , n)
        return Double(s)?.calculator ?? "0"
    }
    
    func toDigits(_ n:Int) -> String {
        let num = Int(floor(Double(self) ?? 0)) 
        //DataLog.d("num " + num.description , tag:"toDigits")
        let fm = "%0" + n.description + "d"
        let str = String(format: fm , num)
        //DataLog.d("str " + str , tag:"toDigits")
        return str
    }
    
    func toThousandUnit(f:Int = 0) -> String {
        guard let num = Double(self) else { return  "0"}
        
        if num < 1000 { return num.calculator }
      
        else if num < 100000 { return
            toDecimal(divid: 1000, f: f) +
            "K" }
        else if num < 100000000 { return
            toDecimal(divid: 100000, f: f) +
            "M" }
        else { return
            toDecimal(divid: 100000000, f: f) +
            "B"}
         
    }
}

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return formatter
    }()
}

extension Formatter {
    static let number = NumberFormatter()
}

extension Locale {
    static let englishUS: Locale = .init(identifier: "en_US")
    static let frenchFR: Locale = .init(identifier: "fr_FR")
    static let portugueseBR: Locale = .init(identifier: "pt_BR")
    static let koreaKR: Locale = .init(identifier: "ko")
    // ... and so on
}
extension Numeric {
    func formatted(with groupingSeparator: String? = nil, style: NumberFormatter.Style, locale: Locale = .current) -> String {
        Formatter.number.locale = locale
        Formatter.number.numberStyle = style
        if let groupingSeparator = groupingSeparator {
            Formatter.number.groupingSeparator = groupingSeparator
        }
        return Formatter.number.string(for: self) ?? ""
    }
    // Localized
    var currency:   String { formatted(style: .currency) }
    // Fixed locales
    var currencyUS: String { formatted(style: .currency, locale: .englishUS) }
    var currencyFR: String { formatted(style: .currency, locale: .frenchFR) }
    var currencyBR: String { formatted(style: .currency, locale: .portugueseBR) }
    var currencyKR: String { formatted(style: .currency, locale: .koreaKR) }
    
    var calculator: String { formatted(with:",", style: .decimal) }
}


extension CGFloat {
    func toRadians() -> CGFloat {
        return self * CGFloat(M_PI) / 180.0
    }
}
