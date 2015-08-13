//
//  main.swift
//  TryJson
//
//  Created by Ushio on 2015/08/12.
//  Copyright © 2015年 Ushio. All rights reserved.
//

import Foundation

// http://weather.livedoor.com/weather_hacks/webservice

func toDate(string: String) -> NSDate {
    var t = tm()
    strptime(
        (string as NSString).UTF8String,
        ("%Y-%m-%dT%T%Z" as NSString).UTF8String,
        &t
    )
    return NSDate(timeIntervalSince1970: NSTimeInterval(mktime(&t)))
}
func toURL(string: String) throws -> NSURL {
    if let url = NSURL(string: string) {
        return url
    }
    throw JsonError.Any("toURL(), string = \(string)")
}
func toDouble(string: String) -> Double {
    return (string as NSString).doubleValue
}

struct WeatherPinpointLocation  : JsonDecodable {
    let link: NSURL
    let name: String
    static func decode(json: Json) throws -> WeatherPinpointLocation {
        return try curry(self.init)
            <*> toURL(json.keyedTake("link"))
            <*> json.keyedTake("name")
    }
}
struct WeatherLocation : JsonDecodable {
    let city: String
    let area: String
    let prefecture: String
    static func decode(json: Json) throws -> WeatherLocation {
        return try curry(self.init)
            <*> json.keyedTake("city")
            <*> json.keyedTake("area")
            <*> json.keyedTake("prefecture")
    }
}

struct WeatherDescription : JsonDecodable {
    let text: String
    let publicTime: NSDate
    static func decode(json: Json) throws -> WeatherDescription {
        return try curry(self.init)
            <*> json.keyedTake("text")
            <*> toDate(json.keyedTake("publicTime"))
    }
}

struct WeatherImage : JsonDecodable {
    let title: String
    let url: NSURL
    let width: Int
    let height: Int
    static func decode(json: Json) throws -> WeatherImage {
        return try curry(self.init)
            <*> json.keyedTake("title")
            <*> toURL(json.keyedTake("url"))
            <*> json.keyedTake("width")
            <*> json.keyedTake("height")
    }
}
struct WeatherTemperature : JsonDecodable {
    let celsius: Double
    let fahrenheit: Double
    static func decode(json: Json) throws -> WeatherTemperature {
        return try curry(self.init)
            <*> toDouble(json.keyedTake("celsius"))
            <*> toDouble(json.keyedTake("fahrenheit"))
    }
}
struct WeatherTemperatureRange : JsonDecodable {
    let min: WeatherTemperature?
    let max: WeatherTemperature?
    static func decode(json: Json) throws -> WeatherTemperatureRange {
        return try curry(self.init)
            <*> json.key("min").takeOrNil()
            <*> json.key("max").takeOrNil()
    }
}
struct WeatherForecast : JsonDecodable {
    let date: NSDate
    let dateLabel: String
    let telop: String
    let temperature: WeatherTemperatureRange
    let image: WeatherImage
    static func decode(json: Json) throws -> WeatherForecast {
        return try curry(self.init)
            <*> toDate(json.keyedTake("date"))
            <*> json.keyedTake("dateLabel")
            <*> json.keyedTake("telop")
            <*> json.keyedTake("temperature")
            <*> json.keyedTake("image")
    }
}
struct WeatherCopyright : JsonDecodable {
    let title: String
    let link: NSURL
    let image: WeatherImage
    let provider: [Json]
    static func decode(json: Json) throws -> WeatherCopyright {
        return try curry(self.init)
            <*> json.keyedTake("title")
            <*> toURL(json.keyedTake("link"))
            <*> json.keyedTake("image")
            <*> json.keyedTake("provider")
    }
}
struct WeatherResponse : JsonDecodable {
    let location: WeatherLocation
    let title: String
    let link: String
    let publicTime: NSDate
    let description_: WeatherDescription
    let forecasts: [WeatherForecast]
    let pinpointLocations: [WeatherPinpointLocation]
    let copyright: WeatherCopyright
    static func decode(json: Json) throws -> WeatherResponse {
//        let a = try curry(self.init)
//            <*> json.keyedTake("location")
//            <*> json.keyedTake("title")
//            <*> json.keyedTake("link")
//            <*> toDate(json.keyedTake("publicTime"))
//            <*> json.keyedTake("description")
//            <*> json.keyedTake("forecasts")
//            <*> json.keyedTake("pinpointLocations")
//        return try a
//            <*> json.keyedTake("copyright")
        return try curry(self.init)
            <*> json.keyedTake("location")
            <*> json.keyedTake("title")
            <*> json.keyedTake("link")
            <*> toDate(json.keyedTake("publicTime"))
            <*> json.keyedTake("description")
            <*> json.keyedTake("forecasts")
            <*> json.keyedTake("pinpointLocations")
            <*> json.keyedTake("copyright")
    }
}

do {
    let url = NSURL(fileURLWithPath: "/Users/Ushio/Documents/Swift/TryJson/weather.json")
    if let data = NSData(contentsOfURL: url) {
        let response: WeatherResponse = try Json.parse(data).take()
        print(response)
    }
} catch  {
    print(error)
}
