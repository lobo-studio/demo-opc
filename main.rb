require 'sinatra'
require 'httparty'
require 'json'
require 'time'
require 'date'
require 'chartkick'

URL_ROOT = "http://a4b0666a.ngrok.io/method=read&param=PVStations.Thailand.Surin"


get '/' do
  total_yield_kwh =  get_value("TotalYieldKwh")
  daty_yield =  get_value("DayYield")

  p total_yield_kwh
  p daty_yield

  @operating_hour =  get_value("OperatingHours")
  @total_income =  get_value("Income")

  @production_data = {"Total Yield Kwh" => total_yield_kwh , "Day Yield" => daty_yield}

  erb :index
end

get '/temperatures' do
    url_env_temp = "#{URL_ROOT}.PVSensors.Measures.EnvTemp.Value"
    url_irradiance_temp = "#{URL_ROOT}.PVSensors.Measures.Irradiance.Value"

    response_temp = HTTParty.get(url_env_temp)
    response_irradiance_temp = HTTParty.get(url_irradiance_temp)

    # temp env
    env_temp_value = response_temp.parsed_response[0]
    time_env_temp =   parse_date(response_temp)

    # temp irradiance NOT DRY
    time_irradiance =   parse_date(response_irradiance_temp)
    irradiance_value = response_temp.parsed_response[0]

    data_temp = [[time_env_temp,env_temp_value],[time_irradiance,irradiance_value]]

    content_type :json
    data_temp.to_json
end


get '/voltages' do
    url_ab  = "#{URL_ROOT}.Measures.GridVoltageAB"
    url_bc  = "#{URL_ROOT}.Measures.GridVoltageBC"
    url_ca  = "#{URL_ROOT}.Measures.GridVoltageCA"


    response_ab = HTTParty.get(url_ab)
    response_bc = HTTParty.get(url_bc)
    response_ca = HTTParty.get(url_ca)

    # temp env
    ab_temp_value = response_ab.parsed_response[0]
    bc_temp_value = response_bc.parsed_response[0]
    ca_temp_value = response_ca.parsed_response[0]

    time_ab =   parse_date(response_ab)
    time_bc =   parse_date(response_bc)
    time_ca =   parse_date(response_ca)


    data_temp = [[time_ab,ab_temp_value],[time_bc,bc_temp_value],[time_ca,ca_temp_value]]

    content_type :json
    data_temp.to_json
end

private
def parse_date(response)
    value = response.parsed_response[2]
    d = DateTime.strptime(value, "%m/%d/%y %H:%M:%S")
    d.to_time.to_i * 1000
end

def get_value(propertie)
    url = "#{URL_ROOT}.Measures.#{propertie}"
    response = HTTParty.get(url)
    response.parsed_response.first
end
