require 'net/http'
require 'pry'
require 'json'

class Delivery

  def self.routs(origins, destinations)
  	if origins == "" || destinations == ""
  		raise "Origins or Destinations is empty"
  	elsif
  		origins == destinations
  		raise "You can't enter two identical values"  		
  	else
	  	uri = URI("https://api.distancematrix.ai/maps/api/distancematrix/json?origins=#{origins}&destinations=#{destinations}&transit_mode=bus&key=JwaD0Kf818SwsmG2EXYYn86tMloBo")
		res = Net::HTTP.get_response(uri)
		response = res.body if res.is_a?(Net::HTTPSuccess)
	end
  end

  def self.distance(origins, destinations)
	distance_value = 0
	response = routs(origins, destinations)
	parse_response = JSON.parse(response, symbolize_names: true)
	parse_response
	parse_response[:rows].each do |values|
		values[:elements].each do |meters|
			distance_value = ((meters[:distance][:value])/1000.0).round(1)
		end		
	end
	distance_value
  end
	
  def self.price(weight, length, width, height, distance)

  	if weight <= 0 || length <= 0 || width <= 0 || height <= 0 
  		raise "Values cannot be negative"
	elsif (length*width*height)/100 <= 0.01
		price = distance.round
	elsif		 	 
		(length*width*height)/100 > 0.01 && weight <= 10
		price = (distance*2).round
	else
		(length*width*height)/100 > 0.01 && weight > 10
		price = (distance*3).round
	end
  end

  def self.cargo_information(weight, length, width, height, origins, destinations)
	distance = distance(origins, destinations)
	price = price(weight, length, width, height, distance)
	info_hash = {weight: weight, length: length, width: width, height: height, distance: distance, price: price}
  end
end
