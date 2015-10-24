//
//  UIFont+TinylogiOSAdditions.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

let kTLIRegularFontName:NSString = "HelveticaNeue"
let kTLIBoldFontName:NSString = "HelveticaNeue-Bold"
let kTLIBoldItalicFontName:NSString = "HelveticaNeue-BoldItalic"
let kTLIItalicFontName:NSString = "HelveticaNeue-Italic"

@available(iOS 8.2, *)
let kTLIRegularSFFontName:NSString = UIFont.systemFontOfSize(10.0, weight: UIFontWeightRegular).fontName //".SFUIText-Regular"
@available(iOS 8.2, *)
let kTLIBoldSFFontName:NSString = UIFont.systemFontOfSize(10.0, weight: UIFontWeightBold).fontName //".SFUIText-Bold"
@available(iOS 8.2, *)
let kTLIBoldItalicSFFontName:NSString = UIFont.systemFontOfSize(10.0, weight: UIFontWeightMedium).fontName //".SFUIText-Medium"
@available(iOS 8.2, *)
let kTLIItalicSFFontName:NSString = UIFont.systemFontOfSize(10.0, weight: UIFontWeightLight).fontName //".SFUIText-Light"

let kTLIFontRegularKey:NSString = "Regular"
let kTLIFontItalicKey:NSString = "Italic"
let kTLIFontBoldKey:NSString = "Bold"
let kTLIFontBoldItalicKey:NSString = "BoldItalic"

let kTLIFontDefaultsKey:NSString = "TLIFontDefaults"
let kTLIFontSanFranciscoKey:NSString = "SanFrancisco"
let kTLIFontHelveticaNeueKey:NSString = "HelveticaNeue"
let kTLIFontAvenirKey:NSString = "Avenir"
let kTLIFontHoeflerKey:NSString = "Hoefler"
let kTLIFontCourierKey:NSString = "Courier"
let kTLIFontGeorgiaKey:NSString = "Georgia"
let kTLIFontMenloKey:NSString = "Menlo"
let kTLIFontTimesNewRomanKey:NSString = "TimesNewRoman"
let kTLIFontPalatinoKey:NSString = "Palatino"
let kTLIFontIowanKey:NSString = "Iowan"

// MARK: Extensions UIFont

extension UIFont {
    
    class func mediumFontWithSize(size:CGFloat) -> UIFont {
        if #available(iOS 9, *) {
          return UIFont.systemFontOfSize(size, weight: UIFontWeightMedium)
        } else {
          return UIFont(name: "HelveticaNeue-Medium", size: size)!
        }
    }
    
    class func regularFontWithSize(size:CGFloat) -> UIFont {
        if #available(iOS 9, *) {
          return UIFont.systemFontOfSize(size, weight: UIFontWeightRegular)
        } else {
          return UIFont(name: "HelveticaNeue", size: size)!
        }
    }
    
    class func tinylogFontMapForFontKey(key:NSString) -> NSDictionary? {
        var fontDictionary:NSDictionary? = nil
        var onceToken:dispatch_once_t = 0
        dispatch_once(&onceToken) { () -> Void in
            
            let defaultFont = NSDictionary(objects: [
                kTLIRegularFontName,
                kTLIItalicFontName,
                kTLIBoldFontName,
                kTLIBoldItalicFontName], forKeys: [
                    kTLIFontRegularKey,
                    kTLIFontItalicKey,
                    kTLIFontBoldKey,
                    kTLIFontBoldItalicKey])

            
            let sf = NSDictionary(objects: [
                ".SFUIText-Regular",
                ".SFUIText-Light",
                ".SFUIText-Bold",
                ".SFUIText-Medium"], forKeys: [
                    kTLIFontRegularKey,
                    kTLIFontItalicKey,
                    kTLIFontBoldKey,
                    kTLIFontBoldItalicKey])
            
            let helveticaNeue = NSDictionary(objects: [
                "HelveticaNeue",
                "HelveticaNeue-Italic",
                "HelveticaNeue-Bold",
                "HelveticaNeue-BoldItalic"], forKeys: [
                    kTLIFontRegularKey,
                    kTLIFontItalicKey,
                    kTLIFontBoldKey,
                    kTLIFontBoldItalicKey])

            let avenir = NSDictionary(objects: [
                "Avenir-Book",
                "Avenir-BookOblique",
                "Avenir-Black",
                "Avenir-BlackOblique"], forKeys: [
                    kTLIFontRegularKey,
                    kTLIFontItalicKey,
                    kTLIFontBoldKey,
                    kTLIFontBoldItalicKey])
            
            let hoefler = NSDictionary(objects: [
                "HoeflerText-Regular",
                "HoeflerText-Italic",
                "HoeflerText-Black",
                "HoeflerText-BlackItalic"], forKeys: [
                    kTLIFontRegularKey,
                    kTLIFontItalicKey,
                    kTLIFontBoldKey,
                    kTLIFontBoldItalicKey])
            
            let courier = NSDictionary(objects: [
                "Courier",
                "Courier-Oblique",
                "Courier-Bold",
                "Courier-BoldOblique"], forKeys: [
                    kTLIFontRegularKey,
                    kTLIFontItalicKey,
                    kTLIFontBoldKey,
                    kTLIFontBoldItalicKey])
            
            let georgia = NSDictionary(objects: [
                "Georgia",
                "Georgia-Italic",
                "Georgia-Bold",
                "Georgia-BoldItalic"], forKeys: [
                    kTLIFontRegularKey,
                    kTLIFontItalicKey,
                    kTLIFontBoldKey,
                    kTLIFontBoldItalicKey])
            
            let menlo = NSDictionary(objects: [
                "Menlo-Regular",
                "Menlo-Italic",
                "Menlo-Bold",
                "Menlo-BoldItalic"], forKeys: [
                    kTLIFontRegularKey,
                    kTLIFontItalicKey,
                    kTLIFontBoldKey,
                    kTLIFontBoldItalicKey])
            
            let timesNewRoman = NSDictionary(objects: [
                "TimesNewRomanPSMT",
                "TimesNewRomanPS-ItalicMT",
                "TimesNewRomanPS-BoldMT",
                "TimesNewRomanPS-BoldItalicMT"], forKeys: [
                    kTLIFontRegularKey,
                    kTLIFontItalicKey,
                    kTLIFontBoldKey,
                    kTLIFontBoldItalicKey])
            
            let palatino = NSDictionary(objects: [
                "Palatino-Roman",
                "Palatino-Italic",
                "Palatino-Bold",
                "Palatino-BoldItalic"], forKeys: [
                    kTLIFontRegularKey,
                    kTLIFontItalicKey,
                    kTLIFontBoldKey,
                    kTLIFontBoldItalicKey])
            
            let iowan = NSDictionary(objects: [
                "IowanOldStyle-Roman",
                "IowanOldStyle-Italic",
                "IowanOldStyle-Bold",
                "IowanOldStyle-BoldItalic"], forKeys: [
                    kTLIFontRegularKey,
                    kTLIFontItalicKey,
                    kTLIFontBoldKey,
                    kTLIFontBoldItalicKey])
        
            if #available(iOS 9, *) {
                
                let defaultFontSF = NSDictionary(objects: [
                    kTLIRegularSFFontName,
                    kTLIItalicSFFontName,
                    kTLIBoldSFFontName,
                    kTLIBoldItalicSFFontName], forKeys: [
                        kTLIFontRegularKey,
                        kTLIFontItalicKey,
                        kTLIFontBoldKey,
                        kTLIFontBoldItalicKey])
                
                fontDictionary = NSDictionary(objects: [
                    defaultFontSF,
                    sf,
                    helveticaNeue,
                    avenir,
                    hoefler,
                    courier,
                    georgia,
                    menlo,
                    timesNewRoman,
                    palatino,
                    iowan], forKeys: [
                        kTLIFontSanFranciscoKey,
                        kTLIFontSanFranciscoKey,
                        kTLIFontHelveticaNeueKey,
                        kTLIFontAvenirKey,
                        kTLIFontHoeflerKey,
                        kTLIFontCourierKey,
                        kTLIFontGeorgiaKey,
                        kTLIFontMenloKey,
                        kTLIFontTimesNewRomanKey,
                        kTLIFontPalatinoKey,
                        kTLIFontIowanKey])
            } else {
                fontDictionary = NSDictionary(objects: [
                    defaultFont,
                    helveticaNeue,
                    avenir,
                    hoefler,
                    courier,
                    georgia,
                    menlo,
                    timesNewRoman,
                    palatino,
                    iowan], forKeys: [
                        kTLIFontHelveticaNeueKey,
                        kTLIFontHelveticaNeueKey,
                        kTLIFontAvenirKey,
                        kTLIFontHoeflerKey,
                        kTLIFontCourierKey,
                        kTLIFontGeorgiaKey,
                        kTLIFontMenloKey,
                        kTLIFontTimesNewRomanKey,
                        kTLIFontPalatinoKey,
                        kTLIFontIowanKey])
            }
        }
        return fontDictionary!.objectForKey(key) as? NSDictionary
    }
    
    class func tinylogFontNameForFontKey(key:NSString, style:NSString)->NSString? {
        return UIFont.tinylogFontMapForFontKey(key)?.objectForKey(style)! as? NSString
    }
    
    class func tinylogFontNameForStyle(style:NSString)->NSString? {
        return UIFont.tinylogFontNameForFontKey(TLISettingsFontPickerViewController.selectedKey()!, style: style)
    }
    
    // MARK: Fonts
    class func tinylogFontOfSize(fontSize:CGFloat, key:NSString)->UIFont? {
        let fontName:NSString? = UIFont.tinylogFontNameForFontKey(key, style: kTLIFontRegularKey)!
        return UIFont(name: fontName! as String, size: fontSize)
    }
    
    class func italicTinylogFontOfSize(fontSize:CGFloat, key:NSString)->UIFont? {
        let fontName:NSString? = UIFont.tinylogFontNameForFontKey(key, style: kTLIFontItalicKey)!
        return UIFont(name: fontName! as String, size: fontSize)
    }
    
    class func boldTinylogFontOfSize(fontSize:CGFloat, key:NSString)->UIFont? {
        let fontName:NSString? = UIFont.tinylogFontNameForFontKey(key, style: kTLIFontBoldKey)!
        return UIFont(name: fontName! as String, size: fontSize)
    }
    
    class func boldItalicTinylogFontOfSize(fontSize:CGFloat, key:NSString)->UIFont? {
        let fontName:NSString? = UIFont.tinylogFontNameForFontKey(key, style: kTLIFontBoldItalicKey)!
        return UIFont(name: fontName! as String, size: fontSize)
    }
    
    // MARK: Standard
    
    class func tinylogFontOfSize(fontSize:CGFloat)->UIFont {
        var size:CGFloat = fontSize
        size += TLISettingsFontPickerViewController.fontSizeAdjustment()
        return UIFont.tinylogFontOfSize(fontSize, key: TLISettingsFontPickerViewController.selectedKey()!)!
    }
    
    class func italicTinylogFontOfSize(fontSize:CGFloat)->UIFont {
        var size:CGFloat = fontSize
        size += TLISettingsFontPickerViewController.fontSizeAdjustment()
        return UIFont.italicTinylogFontOfSize(fontSize, key: TLISettingsFontPickerViewController.selectedKey()!)!
    }
    
    class func boldTinylogFontOfSize(fontSize:CGFloat)->UIFont {
        var size:CGFloat = fontSize
        size += TLISettingsFontPickerViewController.fontSizeAdjustment()
        return UIFont.boldTinylogFontOfSize(fontSize, key: TLISettingsFontPickerViewController.selectedKey()!)!
    }
    
    class func boldItalicTinylogFontOfSize(fontSize:CGFloat)->UIFont {
        var size:CGFloat = fontSize
        size += TLISettingsFontPickerViewController.fontSizeAdjustment()
        return UIFont.boldItalicTinylogFontOfSize(fontSize, key: TLISettingsFontPickerViewController.selectedKey()!)!
    }
    
    // MARK: Interface
    class func tinylogInterfaceFontOfSize(fontSize:CGFloat)->UIFont? {
        return UIFont(name: kTLIRegularFontName as String, size: fontSize)
    }
    
    class func boldTinylogInterfaceFontOfSize(fontSize:CGFloat)->UIFont? {
        return UIFont(name: kTLIBoldFontName as String, size: fontSize)
    }
    
    class func italicTinylogInterfaceFontOfSize(fontSize:CGFloat)->UIFont? {
        return UIFont(name: kTLIItalicFontName as String, size: fontSize)
    }
    
    class func boldItalicTinylogInterfaceFontOfSize(fontSize:CGFloat)->UIFont? {
        return UIFont(name: kTLIBoldItalicFontName as String, size: fontSize)
    }
    
    class func preferredHelveticaNeueFontForTextStyle(textStyle:NSString)->UIFont? {
        
        var fontSize:CGFloat = 16.0
        let contentSize:NSString = UIApplication.sharedApplication().preferredContentSizeCategory
        let fontNameRegular:NSString = "HelveticaNeue"
        let fontNameMedium:NSString = "HelveticaNeue-Medium"
        var fontSizeOffsetDictionary:Dictionary<String, Dictionary<String, AnyObject>>? = nil
        
        var onceToken:dispatch_once_t = 0
        dispatch_once(&onceToken) { () -> Void in
            fontSizeOffsetDictionary = [
                UIContentSizeCategoryLarge:[UIFontTextStyleBody:1,
                    UIFontTextStyleHeadline:1,
                    UIFontTextStyleSubheadline:-1,
                    UIFontTextStyleCaption1:-4,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-3],
                
                UIContentSizeCategoryExtraSmall:[UIFontTextStyleBody:-2,
                    UIFontTextStyleHeadline:-2,
                    UIFontTextStyleSubheadline:-4,
                    UIFontTextStyleCaption1:-5,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-4],
                
                UIContentSizeCategorySmall:[UIFontTextStyleBody:-1,
                    UIFontTextStyleHeadline:-1,
                    UIFontTextStyleSubheadline:-3,
                    UIFontTextStyleCaption1:-5,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-4],
                
                UIContentSizeCategoryMedium:[UIFontTextStyleBody:0,
                    UIFontTextStyleHeadline:0,
                    UIFontTextStyleSubheadline:-2,
                    UIFontTextStyleCaption1:-5,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-4],
                
                UIContentSizeCategoryExtraExtraLarge:[UIFontTextStyleBody:3,
                    UIFontTextStyleHeadline:3,
                    UIFontTextStyleSubheadline:1,
                    UIFontTextStyleCaption1:-2,
                    UIFontTextStyleCaption2:-3,
                    UIFontTextStyleFootnote:-1],
                
                UIContentSizeCategoryExtraExtraExtraLarge:[UIFontTextStyleBody:4,
                    UIFontTextStyleHeadline:4,
                    UIFontTextStyleSubheadline:2,
                    UIFontTextStyleCaption1:-1,
                    UIFontTextStyleCaption2:-2,
                    UIFontTextStyleFootnote:0]]
        }
        
        let content = fontSizeOffsetDictionary![contentSize as String]
        let value:AnyObject = content![textStyle as String]!
        fontSize += value as! CGFloat
        
        if textStyle == UIFontTextStyleHeadline || textStyle ==  UIFontTextStyleSubheadline {
            return UIFont(name: fontNameMedium as String, size: fontSize)
        } else {
            return UIFont(name: fontNameRegular as String, size: fontSize)
        }
    }
    
    class func preferredAvenirFontForTextStyle(textStyle:NSString)->UIFont? {
        
        var fontSize:CGFloat = 16.0
        let contentSize:NSString = UIApplication.sharedApplication().preferredContentSizeCategory
        let fontNameRegular:NSString = "Avenir-Book"
        let fontNameMedium:NSString = "Avenir-Medium"
        var fontSizeOffsetDictionary:Dictionary<String, Dictionary<String, AnyObject>>? = nil
        
        var onceToken:dispatch_once_t = 0
        dispatch_once(&onceToken) { () -> Void in
            fontSizeOffsetDictionary = [
                UIContentSizeCategoryLarge:[UIFontTextStyleBody:1,
                    UIFontTextStyleHeadline:1,
                    UIFontTextStyleSubheadline:-1,
                    UIFontTextStyleCaption1:-4,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-3],
                
                UIContentSizeCategoryExtraSmall:[UIFontTextStyleBody:-2,
                    UIFontTextStyleHeadline:-2,
                    UIFontTextStyleSubheadline:-4,
                    UIFontTextStyleCaption1:-5,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-4],
                
                UIContentSizeCategorySmall:[UIFontTextStyleBody:-1,
                    UIFontTextStyleHeadline:-1,
                    UIFontTextStyleSubheadline:-3,
                    UIFontTextStyleCaption1:-5,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-4],
                
                UIContentSizeCategoryMedium:[UIFontTextStyleBody:0,
                    UIFontTextStyleHeadline:0,
                    UIFontTextStyleSubheadline:-2,
                    UIFontTextStyleCaption1:-5,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-4],
                
                UIContentSizeCategoryExtraExtraLarge:[UIFontTextStyleBody:3,
                    UIFontTextStyleHeadline:3,
                    UIFontTextStyleSubheadline:1,
                    UIFontTextStyleCaption1:-2,
                    UIFontTextStyleCaption2:-3,
                    UIFontTextStyleFootnote:-1],
                
                UIContentSizeCategoryExtraExtraExtraLarge:[UIFontTextStyleBody:4,
                    UIFontTextStyleHeadline:4,
                    UIFontTextStyleSubheadline:2,
                    UIFontTextStyleCaption1:-1,
                    UIFontTextStyleCaption2:-2,
                    UIFontTextStyleFootnote:0]]
        }
        
        let content = fontSizeOffsetDictionary![contentSize as String]
        let value:AnyObject = content![textStyle as String]!
        fontSize += value as! CGFloat
        
        if textStyle == UIFontTextStyleHeadline || textStyle ==  UIFontTextStyleSubheadline {
            return UIFont(name: fontNameMedium as String, size: fontSize)
        } else {
            return UIFont(name: fontNameRegular as String, size: fontSize)
        }
    }
    
    class func preferredCourierFontForTextStyle(textStyle:NSString)->UIFont? {
        var fontSize:CGFloat = 16.0
        let contentSize:NSString = UIApplication.sharedApplication().preferredContentSizeCategory
        let fontNameRegular:NSString = "Courier"
        let fontNameMedium:NSString = "Courier-Bold"
        var fontSizeOffsetDictionary:Dictionary<String, Dictionary<String, AnyObject>>? = nil
        
        var onceToken:dispatch_once_t = 0
        dispatch_once(&onceToken) { () -> Void in
            fontSizeOffsetDictionary = [
                UIContentSizeCategoryLarge:[UIFontTextStyleBody:1,
                    UIFontTextStyleHeadline:1,
                    UIFontTextStyleSubheadline:-1,
                    UIFontTextStyleCaption1:-4,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-3],
                
                UIContentSizeCategoryExtraSmall:[UIFontTextStyleBody:-2,
                    UIFontTextStyleHeadline:-2,
                    UIFontTextStyleSubheadline:-4,
                    UIFontTextStyleCaption1:-5,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-4],
                
                UIContentSizeCategorySmall:[UIFontTextStyleBody:-1,
                    UIFontTextStyleHeadline:-1,
                    UIFontTextStyleSubheadline:-3,
                    UIFontTextStyleCaption1:-5,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-4],
                
                UIContentSizeCategoryMedium:[UIFontTextStyleBody:0,
                    UIFontTextStyleHeadline:0,
                    UIFontTextStyleSubheadline:-2,
                    UIFontTextStyleCaption1:-5,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-4],
                
                UIContentSizeCategoryExtraExtraLarge:[UIFontTextStyleBody:3,
                    UIFontTextStyleHeadline:3,
                    UIFontTextStyleSubheadline:1,
                    UIFontTextStyleCaption1:-2,
                    UIFontTextStyleCaption2:-3,
                    UIFontTextStyleFootnote:-1],
                
                UIContentSizeCategoryExtraExtraExtraLarge:[UIFontTextStyleBody:4,
                    UIFontTextStyleHeadline:4,
                    UIFontTextStyleSubheadline:2,
                    UIFontTextStyleCaption1:-1,
                    UIFontTextStyleCaption2:-2,
                    UIFontTextStyleFootnote:0]]
        }
        
        let content = fontSizeOffsetDictionary![contentSize as String]
        let value:AnyObject = content![textStyle as String]!
        fontSize += value as! CGFloat
        
        if textStyle == UIFontTextStyleHeadline || textStyle ==  UIFontTextStyleSubheadline {
            return UIFont(name: fontNameMedium as String, size: fontSize)
        } else {
            return UIFont(name: fontNameRegular as String, size: fontSize)
        }
    }
    
    class func preferredGeorgiaFontForTextStyle(textStyle:NSString)->UIFont? {
        var fontSize:CGFloat = 16.0
        let contentSize:NSString = UIApplication.sharedApplication().preferredContentSizeCategory
        let fontNameRegular:NSString = "Georgia"
        let fontNameMedium:NSString = "Georgia-Bold"
        var fontSizeOffsetDictionary:Dictionary<String, Dictionary<String, AnyObject>>? = nil
        
        var onceToken:dispatch_once_t = 0
        dispatch_once(&onceToken) { () -> Void in
            fontSizeOffsetDictionary = [
                UIContentSizeCategoryLarge:[UIFontTextStyleBody:1,
                    UIFontTextStyleHeadline:1,
                    UIFontTextStyleSubheadline:-1,
                    UIFontTextStyleCaption1:-4,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-3],
                
                UIContentSizeCategoryExtraSmall:[UIFontTextStyleBody:-2,
                    UIFontTextStyleHeadline:-2,
                    UIFontTextStyleSubheadline:-4,
                    UIFontTextStyleCaption1:-5,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-4],
                
                UIContentSizeCategorySmall:[UIFontTextStyleBody:-1,
                    UIFontTextStyleHeadline:-1,
                    UIFontTextStyleSubheadline:-3,
                    UIFontTextStyleCaption1:-5,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-4],
                
                UIContentSizeCategoryMedium:[UIFontTextStyleBody:0,
                    UIFontTextStyleHeadline:0,
                    UIFontTextStyleSubheadline:-2,
                    UIFontTextStyleCaption1:-5,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-4],
                
                UIContentSizeCategoryExtraExtraLarge:[UIFontTextStyleBody:3,
                    UIFontTextStyleHeadline:3,
                    UIFontTextStyleSubheadline:1,
                    UIFontTextStyleCaption1:-2,
                    UIFontTextStyleCaption2:-3,
                    UIFontTextStyleFootnote:-1],
                
                UIContentSizeCategoryExtraExtraExtraLarge:[UIFontTextStyleBody:4,
                    UIFontTextStyleHeadline:4,
                    UIFontTextStyleSubheadline:2,
                    UIFontTextStyleCaption1:-1,
                    UIFontTextStyleCaption2:-2,
                    UIFontTextStyleFootnote:0]]
        }
        
        let content = fontSizeOffsetDictionary![contentSize as String]
        let value:AnyObject = content![textStyle as String]!
        fontSize += value as! CGFloat
        
        if textStyle == UIFontTextStyleHeadline || textStyle ==  UIFontTextStyleSubheadline {
            return UIFont(name: fontNameMedium as String, size: fontSize)
        } else {
            return UIFont(name: fontNameRegular as String, size: fontSize)
        }
    }
    
    class func preferredMenloFontForTextStyle(textStyle:NSString)->UIFont? {
        var fontSize:CGFloat = 16.0
        let contentSize:NSString = UIApplication.sharedApplication().preferredContentSizeCategory
        let fontNameRegular:NSString = "Menlo-Regular"
        let fontNameMedium:NSString = "Menlo-Bold"
        var fontSizeOffsetDictionary:Dictionary<String, Dictionary<String, AnyObject>>? = nil
        
        var onceToken:dispatch_once_t = 0
        dispatch_once(&onceToken) { () -> Void in
            fontSizeOffsetDictionary = [
                UIContentSizeCategoryLarge:[UIFontTextStyleBody:1,
                    UIFontTextStyleHeadline:1,
                    UIFontTextStyleSubheadline:-1,
                    UIFontTextStyleCaption1:-4,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-3],
                
                UIContentSizeCategoryExtraSmall:[UIFontTextStyleBody:-2,
                    UIFontTextStyleHeadline:-2,
                    UIFontTextStyleSubheadline:-4,
                    UIFontTextStyleCaption1:-5,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-4],
                
                UIContentSizeCategorySmall:[UIFontTextStyleBody:-1,
                    UIFontTextStyleHeadline:-1,
                    UIFontTextStyleSubheadline:-3,
                    UIFontTextStyleCaption1:-5,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-4],
                
                UIContentSizeCategoryMedium:[UIFontTextStyleBody:0,
                    UIFontTextStyleHeadline:0,
                    UIFontTextStyleSubheadline:-2,
                    UIFontTextStyleCaption1:-5,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-4],
                
                UIContentSizeCategoryExtraExtraLarge:[UIFontTextStyleBody:3,
                    UIFontTextStyleHeadline:3,
                    UIFontTextStyleSubheadline:1,
                    UIFontTextStyleCaption1:-2,
                    UIFontTextStyleCaption2:-3,
                    UIFontTextStyleFootnote:-1],
                
                UIContentSizeCategoryExtraExtraExtraLarge:[UIFontTextStyleBody:4,
                    UIFontTextStyleHeadline:4,
                    UIFontTextStyleSubheadline:2,
                    UIFontTextStyleCaption1:-1,
                    UIFontTextStyleCaption2:-2,
                    UIFontTextStyleFootnote:0]]
        }
        
        let content = fontSizeOffsetDictionary![contentSize as String]
        let value:AnyObject = content![textStyle as String]!
        fontSize += value as! CGFloat
        
        if textStyle == UIFontTextStyleHeadline || textStyle ==  UIFontTextStyleSubheadline {
            return UIFont(name: fontNameMedium as String, size: fontSize)
        } else {
            return UIFont(name: fontNameRegular as String, size: fontSize)
        }
    }
    
    class func preferredTimesNewRomanFontForTextStyle(textStyle:NSString)->UIFont? {
        var fontSize:CGFloat = 16.0
        let contentSize:NSString = UIApplication.sharedApplication().preferredContentSizeCategory
        let fontNameRegular:NSString = "TimesNewRomanPSMT"
        let fontNameMedium:NSString = "TimesNewRomanPS-BoldMT"
        var fontSizeOffsetDictionary:Dictionary<String, Dictionary<String, AnyObject>>? = nil
        
        var onceToken:dispatch_once_t = 0
        dispatch_once(&onceToken) { () -> Void in
            fontSizeOffsetDictionary = [
                UIContentSizeCategoryLarge:[UIFontTextStyleBody:1,
                    UIFontTextStyleHeadline:1,
                    UIFontTextStyleSubheadline:-1,
                    UIFontTextStyleCaption1:-4,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-3],
                
                UIContentSizeCategoryExtraSmall:[UIFontTextStyleBody:-2,
                    UIFontTextStyleHeadline:-2,
                    UIFontTextStyleSubheadline:-4,
                    UIFontTextStyleCaption1:-5,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-4],
                
                UIContentSizeCategorySmall:[UIFontTextStyleBody:-1,
                    UIFontTextStyleHeadline:-1,
                    UIFontTextStyleSubheadline:-3,
                    UIFontTextStyleCaption1:-5,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-4],
                
                UIContentSizeCategoryMedium:[UIFontTextStyleBody:0,
                    UIFontTextStyleHeadline:0,
                    UIFontTextStyleSubheadline:-2,
                    UIFontTextStyleCaption1:-5,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-4],
                
                UIContentSizeCategoryExtraExtraLarge:[UIFontTextStyleBody:3,
                    UIFontTextStyleHeadline:3,
                    UIFontTextStyleSubheadline:1,
                    UIFontTextStyleCaption1:-2,
                    UIFontTextStyleCaption2:-3,
                    UIFontTextStyleFootnote:-1],
                
                UIContentSizeCategoryExtraExtraExtraLarge:[UIFontTextStyleBody:4,
                    UIFontTextStyleHeadline:4,
                    UIFontTextStyleSubheadline:2,
                    UIFontTextStyleCaption1:-1,
                    UIFontTextStyleCaption2:-2,
                    UIFontTextStyleFootnote:0]]
        }
        
        let content = fontSizeOffsetDictionary![contentSize as String]
        let value:AnyObject = content![textStyle as String]!
        fontSize += value as! CGFloat
        
        if textStyle == UIFontTextStyleHeadline || textStyle ==  UIFontTextStyleSubheadline {
            return UIFont(name: fontNameMedium as String, size: fontSize)
        } else {
            return UIFont(name: fontNameRegular as String, size: fontSize)
        }
    }
    
    class func preferredPalatinoFontForTextStyle(textStyle:NSString)->UIFont? {
        var fontSize:CGFloat = 16.0
        let contentSize:NSString = UIApplication.sharedApplication().preferredContentSizeCategory
        let fontNameRegular:NSString = "Palatino-Roman"
        let fontNameMedium:NSString = "Palatino-Bold"
        var fontSizeOffsetDictionary:Dictionary<String, Dictionary<String, AnyObject>>? = nil
        
        var onceToken:dispatch_once_t = 0
        dispatch_once(&onceToken) { () -> Void in
            fontSizeOffsetDictionary = [
                UIContentSizeCategoryLarge:[UIFontTextStyleBody:1,
                    UIFontTextStyleHeadline:1,
                    UIFontTextStyleSubheadline:-1,
                    UIFontTextStyleCaption1:-4,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-3],
                
                UIContentSizeCategoryExtraSmall:[UIFontTextStyleBody:-2,
                    UIFontTextStyleHeadline:-2,
                    UIFontTextStyleSubheadline:-4,
                    UIFontTextStyleCaption1:-5,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-4],
                
                UIContentSizeCategorySmall:[UIFontTextStyleBody:-1,
                    UIFontTextStyleHeadline:-1,
                    UIFontTextStyleSubheadline:-3,
                    UIFontTextStyleCaption1:-5,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-4],
                
                UIContentSizeCategoryMedium:[UIFontTextStyleBody:0,
                    UIFontTextStyleHeadline:0,
                    UIFontTextStyleSubheadline:-2,
                    UIFontTextStyleCaption1:-5,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-4],
                
                UIContentSizeCategoryExtraExtraLarge:[UIFontTextStyleBody:3,
                    UIFontTextStyleHeadline:3,
                    UIFontTextStyleSubheadline:1,
                    UIFontTextStyleCaption1:-2,
                    UIFontTextStyleCaption2:-3,
                    UIFontTextStyleFootnote:-1],
                
                UIContentSizeCategoryExtraExtraExtraLarge:[UIFontTextStyleBody:4,
                    UIFontTextStyleHeadline:4,
                    UIFontTextStyleSubheadline:2,
                    UIFontTextStyleCaption1:-1,
                    UIFontTextStyleCaption2:-2,
                    UIFontTextStyleFootnote:0]]
        }
        
        let content = fontSizeOffsetDictionary![contentSize as String]
        let value:AnyObject = content![textStyle as String]!
        fontSize += value as! CGFloat
        
        if textStyle == UIFontTextStyleHeadline || textStyle ==  UIFontTextStyleSubheadline {
            return UIFont(name: fontNameMedium as String, size: fontSize)
        } else {
            return UIFont(name: fontNameRegular as String, size: fontSize)
        }
    }
    
    class func preferredIowanFontForTextStyle(textStyle:NSString)->UIFont? {
        var fontSize:CGFloat = 16.0
        let contentSize:NSString = UIApplication.sharedApplication().preferredContentSizeCategory
        let fontNameRegular:NSString = "IowanOldStyle-Roman"
        let fontNameMedium:NSString = "IowanOldStyle-Bold"
        var fontSizeOffsetDictionary:Dictionary<String, Dictionary<String, AnyObject>>? = nil
        
        var onceToken:dispatch_once_t = 0
        dispatch_once(&onceToken) { () -> Void in
            fontSizeOffsetDictionary = [
                UIContentSizeCategoryLarge:[UIFontTextStyleBody:1,
                    UIFontTextStyleHeadline:1,
                    UIFontTextStyleSubheadline:-1,
                    UIFontTextStyleCaption1:-4,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-3],
                
                UIContentSizeCategoryExtraSmall:[UIFontTextStyleBody:-2,
                    UIFontTextStyleHeadline:-2,
                    UIFontTextStyleSubheadline:-4,
                    UIFontTextStyleCaption1:-5,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-4],
                
                UIContentSizeCategorySmall:[UIFontTextStyleBody:-1,
                    UIFontTextStyleHeadline:-1,
                    UIFontTextStyleSubheadline:-3,
                    UIFontTextStyleCaption1:-5,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-4],
                
                UIContentSizeCategoryMedium:[UIFontTextStyleBody:0,
                    UIFontTextStyleHeadline:0,
                    UIFontTextStyleSubheadline:-2,
                    UIFontTextStyleCaption1:-5,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-4],
                
                UIContentSizeCategoryExtraExtraLarge:[UIFontTextStyleBody:3,
                    UIFontTextStyleHeadline:3,
                    UIFontTextStyleSubheadline:1,
                    UIFontTextStyleCaption1:-2,
                    UIFontTextStyleCaption2:-3,
                    UIFontTextStyleFootnote:-1],
                
                UIContentSizeCategoryExtraExtraExtraLarge:[UIFontTextStyleBody:4,
                    UIFontTextStyleHeadline:4,
                    UIFontTextStyleSubheadline:2,
                    UIFontTextStyleCaption1:-1,
                    UIFontTextStyleCaption2:-2,
                    UIFontTextStyleFootnote:0]]
        }
        
        let content = fontSizeOffsetDictionary![contentSize as String]
        let value:AnyObject = content![textStyle as String]!
        fontSize += value as! CGFloat
        
        if textStyle == UIFontTextStyleHeadline || textStyle ==  UIFontTextStyleSubheadline {
            return UIFont(name: fontNameMedium as String, size: fontSize)
        } else {
            return UIFont(name: fontNameRegular as String, size: fontSize)
        }
    }
    
    class func preferredSFFontForTextStyle(textStyle:NSString)->UIFont? {
        var fontSize:CGFloat = 16.0
        let contentSize:NSString = UIApplication.sharedApplication().preferredContentSizeCategory
        //let fontNameRegular:NSString = "IowanOldStyle-Roman"
        //let fontNameMedium:NSString = "IowanOldStyle-Bold"
        var fontSizeOffsetDictionary:Dictionary<String, Dictionary<String, AnyObject>>? = nil
        
        var onceToken:dispatch_once_t = 0
        dispatch_once(&onceToken) { () -> Void in
            fontSizeOffsetDictionary = [
                UIContentSizeCategoryLarge:[UIFontTextStyleBody:1,
                    UIFontTextStyleHeadline:1,
                    UIFontTextStyleSubheadline:-1,
                    UIFontTextStyleCaption1:-4,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-3],
                
                UIContentSizeCategoryExtraSmall:[UIFontTextStyleBody:-2,
                    UIFontTextStyleHeadline:-2,
                    UIFontTextStyleSubheadline:-4,
                    UIFontTextStyleCaption1:-5,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-4],
                
                UIContentSizeCategorySmall:[UIFontTextStyleBody:-1,
                    UIFontTextStyleHeadline:-1,
                    UIFontTextStyleSubheadline:-3,
                    UIFontTextStyleCaption1:-5,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-4],
                
                UIContentSizeCategoryMedium:[UIFontTextStyleBody:0,
                    UIFontTextStyleHeadline:0,
                    UIFontTextStyleSubheadline:-2,
                    UIFontTextStyleCaption1:-5,
                    UIFontTextStyleCaption2:-5,
                    UIFontTextStyleFootnote:-4],
                
                UIContentSizeCategoryExtraExtraLarge:[UIFontTextStyleBody:3,
                    UIFontTextStyleHeadline:3,
                    UIFontTextStyleSubheadline:1,
                    UIFontTextStyleCaption1:-2,
                    UIFontTextStyleCaption2:-3,
                    UIFontTextStyleFootnote:-1],
                
                UIContentSizeCategoryExtraExtraExtraLarge:[UIFontTextStyleBody:4,
                    UIFontTextStyleHeadline:4,
                    UIFontTextStyleSubheadline:2,
                    UIFontTextStyleCaption1:-1,
                    UIFontTextStyleCaption2:-2,
                    UIFontTextStyleFootnote:0]]
        }
        
        let content = fontSizeOffsetDictionary![contentSize as String]
        let value:AnyObject = content![textStyle as String]!
        fontSize += value as! CGFloat
        
        if textStyle == UIFontTextStyleHeadline || textStyle ==  UIFontTextStyleSubheadline {
       
            if #available(iOS 8.2, *) {
                return UIFont.systemFontOfSize(fontSize, weight: UIFontWeightMedium)
            }
        } else {

            if #available(iOS 8.2, *) {
                return UIFont.systemFontOfSize(fontSize, weight: UIFontWeightRegular)
            }
        }
        return  UIFont.systemFontOfSize(fontSize)
    }
}

