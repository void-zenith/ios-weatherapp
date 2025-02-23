//
//  ContentView.swift
//  zenithrajbhandari_assign2
//
//  Created by zenith mac on 2024-03-31.
import Alamofire
import SwiftUI

struct ContentView: View {
    @State private var results = [ForecastDay]()
    
    let blueSky = Color.init(red:135/255, green: 206/255, blue: 235/255)
    let greySky = Color.init(red:47/255, green: 79/255, blue: 79/255)
    @State var queryCity: String = ""
    @State var contentSize: CGSize = .zero
    @State var textFieldHeight = 15.0
    @State var hourlyForecast = [Hour]()
    @State var weatherEmoji = "☀️"
    @State var currentTemp = 0
    @State var conditionText = "Slightly Overcast"
    @State var cityName = "Toronto"
    @State var loading  = true
    @State var backgroundColor = Color.init(red:135/255, green: 206/255, blue: 235/255)
    var body: some View {
        if loading {
            ZStack{
                Color.init(backgroundColor).ignoresSafeArea()
                ProgressView()
                    .scaleEffect(2, anchor: .center).progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                    .frame(maxWidth:   .infinity, maxHeight: .infinity).task {
                        await fetchWeather(queryCity: "")
                    }
            }
        } else{
            VStack {
                Spacer()
                TextField("Enter city name or postal code", text: $queryCity)
                    .textFieldStyle(PlainTextFieldStyle()).background(Rectangle().foregroundColor(.white.opacity(0.2)).cornerRadius(25).frame(height: 50))
                    .padding(.leading, 40).padding(.trailing, 40).padding(.bottom, 15).padding(.top, textFieldHeight)
                    .multilineTextAlignment(.center)
                    .accentColor(.white)
                    .font(Font.system(size: 20, design: .default)).onSubmit {
                        Task{
                            await fetchWeather(queryCity: queryCity)
                        }
                        withAnimation{
                            textFieldHeight = 15
                        }
                    }
                Text("\(cityName)").font(.system(size: 35)).bold().shadow(color: .black.opacity(0.2), radius: 1, x:0, y:2)
                Text("\(Date().formatted(date:.complete, time: .omitted))").font(.system(size: 16)).shadow(color: .black.opacity(0.2), radius: 1, x:0, y:2)
                Text(weatherEmoji).font(
                    .system(size: 110)).shadow(radius: 50).shadow(color: .black.opacity(0.2), radius: 1, x:0, y:2)
                Text("\(currentTemp)°C").font(.system(size: 70)).bold().shadow(color: .black.opacity(0.2), radius: 1, x:0, y:2)
                Text("\(conditionText)").font(.system(size: 18)).bold().shadow(color: .black.opacity(0.2), radius: 1, x:0, y:2)
                Spacer()
                Spacer()
                Spacer()
                Text("Hourly Forecast").font(.system(size: 17))
                    .foregroundStyle(.white)
                    .shadow(color:.black.opacity(0.2), radius: 1, x:0,y:2).bold()
                ScrollView(.horizontal, showsIndicators: false){
                    HStack{
                        Spacer()
                        ForEach(hourlyForecast){
                            forecast in VStack{
                                Text("\(getShortTime(time:forecast.time))").shadow(color: .black.opacity(0.2), radius: 1, x:0, y:2)
                                Text("\(getWeatherEmoji(code: forecast.condition.code))").shadow(color: .black.opacity(0.2), radius: 1, x:0, y:2)
                                Text("\(Int(forecast.temp_c))").shadow(color: .black.opacity(0.2), radius: 1, x:0, y:2)
                            }
                            .frame(width: 50, height: 90)
                        }
                        Spacer()
                    }
                    .background(Color.white.blur(radius: 75).opacity(0.35)).cornerRadius(15)
                    .cornerRadius(15)
                }
                .padding(.top,.zero).padding(.leading, 18).padding(.trailing, 18)

                Spacer()
                Text("3 day Forecast").font(.system(size: 17))
                    .foregroundStyle(.white)
                    .shadow(color:.black.opacity(0.2), radius: 1, x:0,y:2).bold()

                List (results){ forecast in
                    HStack(alignment: .center, spacing: nil){
                        Text("\(getShortDate(epoch:forecast.date_epoch))").frame(maxWidth: 50, alignment: .leading).bold()
                        Text("\(getWeatherEmoji(code: forecast.day.condition.code))").frame(maxWidth: 30, alignment: .leading).bold()
                        Text("\(Int(forecast.day.avgtemp_c))°C")
                        Spacer()
                        Text("\(forecast.day.condition.text)").frame(maxWidth:  .infinity, alignment: .leading)
                    }.listRowBackground(Color.white.blur(radius: 75).opacity(0.5))
                }.contentMargins(.vertical, 0)
                    .scrollContentBackground(.hidden).preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
                Spacer()
                Text("Data supplied by weather api").foregroundStyle(.white).font(.system(size: 14))
            }.background(backgroundColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .task {
                    await  fetchWeather(queryCity: " ")
                }
        }
    }
    func getFocus(focused: Bool){
        withAnimation{
            textFieldHeight = 130
        }
    }
    func fetchWeather(queryCity: String) async{
        var queryText = ""
        
        if(queryCity == ""){
            queryText = "http://api.weatherapi.com/v1/forecast.json?key=30ba94b894ff447a8a6154542243103&q=M1G3T&days=3&api=no&alerts=no"
        }else {
            queryText = "http://api.weatherapi.com/v1/forecast.json?key=30ba94b894ff447a8a6154542243103&q=\(queryCity)&days=3&api=no&alerts=no"
        }
        let request = AF.request(queryText)
        
        request.responseDecodable(of: Weather.self){
            response in switch response.result {
            case .success(let weather):
//                print(weather.location.name)
                var index = 0
                
                
                cityName = weather.location.name
                results = weather.forecast.forecastday
                
                if Date(timeIntervalSince1970: TimeInterval(results[0].date_epoch)).formatted(Date.FormatStyle().weekday(.abbreviated)) != Date().formatted(Date.FormatStyle().weekday(.abbreviated)){
                    index = 1
                }
                currentTemp = Int(results[index].day.avgtemp_c)
                backgroundColor = getBackgroundColor(code: results[index].day.condition.code)
                
                hourlyForecast = results[index].hour
                weatherEmoji = getWeatherEmoji(code:results[index].day.condition.code)
                conditionText = results[index].day.condition.text
                loading = false
            case .failure(let error):
                print(error)
            }
        }
    }
  
}
#Preview {
    ContentView()
}
