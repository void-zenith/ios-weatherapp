//
//  Models.swift
//  zenithrajbhandari_assign2
//
//  Created by zenith mac on 2024-04-07.
//
import SwiftUI
import Foundation

struct Weather: Codable{
    var location: location
    var forecast: Forecast
}
struct Forecast: Codable{
    var forecastday: [ForecastDay]
}
struct ForecastDay: Codable, Identifiable{
    var date_epoch: Int
    var id: Int {date_epoch}
    var day: Day
    var hour: [Hour]
}
struct Day: Codable{
    var avgtemp_c: Double
    var condition: Condition
}

struct Condition: Codable{
    var text: String
    var code: Int
}
struct location: Codable{
    var name: String
}


struct Hour: Codable, Identifiable{
    var time_epoch: Int
    var time: String
    var temp_c: Double
    var condition: Condition
    var id: Int {time_epoch}
}
