require 'rspec'
require './delivery_task.rb'
require 'vcr'
require 'pry'

VCR.configure do |c|
	c.cassette_library_dir = "spec/vcr"
	c.hook_into :webmock
	vcr_mode = :once
end

RSpec.describe Delivery do

	describe '#routs' do
		context 'Field existence check' do
			subject(:routs) {described_class.routs("Krasnodar", "London")}
			it 'return distance field' do
				VCR.use_cassette("Krasnodar_London") do
					expect(routs).to include("distance")
				end
			end
		end

		context 'When specifying one city' do
			subject(:rout_without_country) {described_class.routs("Krasnodar", "")}
			it 'return raise error' do
				expect{rout_without_country}.to raise_error("Origins or Destinations is empty")
			end
		end

		context 'When specifying two identical cities' do
			subject(:equal_routes) {described_class.routs("Krasnodar", "Krasnodar")}
			it 'return raise error' do
				expect{equal_routes}.to raise_error("You can't enter two identical values")
			end
		end
	end

	describe '#distance' do
		context 'Getting the distance between two cities' do
			subject(:distance) {described_class.distance("Krasnodar", "London")}
			it 'return distance value' do
				VCR.use_cassette("Krasnodar_London") do
					expect(distance).to eq(3621.6)
				end
			end
		end
	end

	describe '#price' do
		subject(:distance) {described_class.distance("Krasnodar", "London")}
		context 'Price when cargo <= 1 cub meter' do
			subject(:price1) {described_class.price(12.6, 1.0, 1.0, 1.0, distance)}
			it 'returned price' do
				VCR.use_cassette("Krasnodar_London") do
					expect(price1).to eq(3622)
				end
			end
		end
		context 'Price when cargo > 1 cub meter && weight <= 10' do
			subject(:price2) {described_class.price(9.5, 1.0, 2.0, 3.0, distance)}
			it 'returned price' do
				VCR.use_cassette("Krasnodar_London") do
					expect(price2).to eq(7243)
				end
			end
		end
		context 'Price when cargo > 1 cub meter && weight > 10' do
			subject(:price3) {described_class.price(25.9, 1.0, 2.0, 3.0, distance)}
			it 'returned price' do
				VCR.use_cassette("Krasnodar_London") do
					expect(price3).to eq(10865)
				end
			end
		end
		context 'When incorrect values' do
			subject(:negative_value) {described_class.price(25.9, -1.0, 0.0, 3.0, distance)}
			it 'return raise error' do
				VCR.use_cassette("Krasnodar_London") do
					expect{negative_value}.to raise_error("Values cannot be negative")
				end
			end
		end
	end

	describe '#cargo_information' do
		context 'Response with entered information' do
			subject(:information) {described_class.cargo_information(25.9, 1.0, 2.0, 3.0, "Krasnodar", "London")}
			it 'return hash' do
				VCR.use_cassette("Krasnodar_London") do
					expect(information).to include(:weight=>25.9, :length=>1.0, :width=>2.0, :height=>3.0, :distance=>3621.6, :price=>10865)
				end
			end
		end
	end
end