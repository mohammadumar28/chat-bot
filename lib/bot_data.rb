require_relative '../config/environment.rb'
require 'humanize'

module BotData
  def self.get_weather(api_key, city)
    params = {
      appid: api_key,
      q: city,
      units: 'metric'
    }
    uri = URI('https://api.openweathermap.org/data/2.5/weather')
    uri.query = URI.encode_www_form(params)
    json = Net::HTTP.get(uri)
    data = JSON.parse(json)

    return false if data['name'].nil?

    info = {
      city: data['name'],
      temp: data['main']['temp'],
      weather: data['weather'][0]['main'],
      description: data['weather'][0]['description'],
      humidity: data['main']['humidity'],
      wind: data['wind']['speed'],
      feels_like: data['main']['feels_like']
    }
    info
  end

  def self.covid_cases(country)
    country = country.include?(' ') ? country.split(' ').join('-') : country

    uri = URI("https://corona.lmao.ninja/v2/countries/#{country}")
    json = Net::HTTP.get(uri)
    data = JSON.parse(json)
    return false unless data['message'].nil?

    info = {
      country: data['country'],
      totalCases: data['cases'],
      activeCases: data['active'],
      critical: data['critical'],
      deaths: data['deaths'],
      recovered: data['recovered'],
      todayCases: data['todayCases'],
      population: data['population'],
      continent: data['continent']
    }
    info
  end

  def self.weather_text(method_name)
    "Weather Now in ___#{method_name[:city]}_\r__

    Temperature: *#{method_name[:temp]} C*

    Feels Like: *#{method_name[:feels_like]} C*

    Weather: *#{method_name[:weather]}*

    Description: *#{method_name[:description]}*

    Humidity: *#{method_name[:humidity]}%*

    Wind Speed: *#{method_name[:wind]} km/h*"
  end

  def self.covid_text(method_name)
    "Covid-19 Statistics for __#{method_name[:country]}__ :

    Population: *#{number_comma(method_name[:population])}* (#{method_name[:population].humanize.capitalize})

    Total Cases: *#{number_comma(method_name[:totalCases])}* (#{method_name[:totalCases].humanize.capitalize})

    Today's Cases: *#{number_comma(method_name[:todayCases])}* (#{method_name[:todayCases].humanize.capitalize})

    Active Cases: *#{number_comma(method_name[:activeCases])}* (#{method_name[:activeCases].humanize.capitalize})

    Critical Cases: *#{number_comma(method_name[:critical])}* (#{method_name[:critical].humanize.capitalize})

    Recovered Cases: *#{number_comma(method_name[:recovered])}* (#{method_name[:recovered].humanize.capitalize})

    Total Deaths: *#{number_comma(method_name[:deaths])}* (#{method_name[:deaths].humanize.capitalize})

    Continent: *#{method_name[:continent]}*"
  end

  def self.number_comma(number)
    number.to_s.chars.to_a.reverse.each_slice(3).map(&:join).join(',').reverse
  end

  def self.welcome
    "I am a Weather and Covid-19 Bot\n
    You can know about the current weather of any city.\n
    You can know about the Covid-19 Cases and other info of any country.\n
    List of commands you can use in this bot:\n
    Covid-19 command: *covid/*`<replace me with country name>`\n
    Weather command: *weather/*`<replace me with city name>`\n
    Date command: /date (To know the date)"
  end

  def self.help
    "List of Commands: \n
    1. /start: Start the bot\n
    2. covid/_<country-name>_: Get Covid-19 details\n
    3. weather/_<city-name>_: Get today's weather\n
    4. /date: Get today's date\n
    5. /help: Get the list of all commands.\n
    How to get Covid-19 details for a country?\n
    Type `covid/usa` to get the details for United States\n
    How to get weather details for a city?\n
    Type `weather/london` to get the weather for London"
  end

  def self.unknown_command
    "I couldn\'t understand that command, please write a valid command."
  end

  def self.unknown_country
    "Country not found or doesn't have any cases"
  end

  def self.unknown_city
    'City not found, please enter a valid city name.'
  end

  def self.date
    "Today's date is *#{Time.new.day}-#{Time.new.month}-#{Time.new.year}*"
  end

  OPENWEATHER_API = ENV['OPENWEATHER_API']
  TELEGRAM_TOKEN = ENV['TELEGRAM_TOKEN']
end
