require 'turkish_support'
require 'set'

module Status
  FIND_ONLY_TOWN = 1
  FIND_ONLY_NEIGHBORHOOD = 2
  FIND_TOWN_AND_NEIGHBORHOOD = 3
  FIND_NOTHING = 4
end

class CanSpeakInTurkish
  using TurkishSupport
  
  def down(string)
    string.downcase
  end
end

class ResultAdress

  @@total_counter = 0
  @@only_town_counter = 0
  @@only_neigborhood_counter = 0
  @@town_and_neighborhood_counter = 0
  @@nothing_counter = 0

  def initialize(full_address = nil, town = nil , neighborhood = nil)
    @town = town
    @neighborhood = neighborhood
    @status = nil
    @full_address = full_address
  end

  def self.get_total_counter
    @@total_counter
  end

  def self.get_town_counter
    @@only_town_counter
  end

  def self.get_neighborhood_counter
    @@only_neigborhood_counter
  end

  def self.get_nothing_counter
    @@nothing_counter
  end

  def self.get_town_and_neighborhood_counter
    @@town_and_neighborhood_counter
  end

  def get_full_address
    @full_address
  end

  def get_town
    @town
  end

  def get_neighborhood
    @neighborhood
  end

  def set_town(town = nil)
    @town = town
  end

  def set_neighborhood(neighborhood = nil )
    @neighborhood = neighborhood
  end

  def set_town(town = nil)
    @town = town
  end

  def set_neighborhood(neighborhood = nil)
    @neighborhood = neighborhood
  end

  def find_status

    @@total_counter = @@total_counter + 1

    if @town != nil and @neighborhood != nil
      @status = Status::FIND_TOWN_AND_NEIGHBORHOOD
      @@town_and_neighborhood_counter = @@town_and_neighborhood_counter + 1
    elsif @town != nil and @neighborhood == nil
      @status = Status::FIND_ONLY_TOWN
      @@only_town_counter = @@only_town_counter + 1
    elsif @town == nil and @neighborhood != nil
      @status = Status::FIND_ONLY_NEIGHBORHOOD
      @@only_neigborhood_counter = @@only_neigborhood_counter + 1
    else
      @status = Status::FIND_NOTHING
      @@nothing_counter = @@nothing_counter + 1
    end

    return @status
  end

end

def read_file_and_convert_array(file_name)
  set = Set.new
  file = File.open(file_name)
  file_data = file.readlines.map(&:chomp)
  file_data.each do |item|
    set.add(CanSpeakInTurkish.new.down(item))
  end

  file.close
  return set.to_a
end

array_of_result_address = Array.new

ilce_array = read_file_and_convert_array("ilce.txt")
mahalle_array = read_file_and_convert_array("mahalle.txt")
address_array = read_file_and_convert_array("adress.txt")
puts address_array.length

adress_array_counter = 0
while adress_array_counter < address_array.length
  result = ResultAdress.new(address_array[adress_array_counter])

  str = address_array[adress_array_counter].split(" ")

  string_counter = 0
  while string_counter < str.length

    #if str[string_counter].length == 5 and str[string_counter].include? "34"
    # puts str[string_counter]
    #end

    ilce_array.each do |town|
      if str[string_counter].include? town
        result.set_town(town)
      end
    end

    if mahalle_array.each do |neighborhood|

      if str[string_counter] == neighborhood and str[string_counter+1] != nil and (str[string_counter+1].include? "mah" or str[string_counter+1].include? "mh")
        result.set_neighborhood(neighborhood)
      elsif  neighborhood.include? str[string_counter] and str[string_counter+1] != nil and neighborhood.include? str[string_counter + 1]
        result.set_neighborhood(neighborhood)
      end

    end
    end
    string_counter = string_counter + 1
  end

  array_of_result_address.append(result)
  adress_array_counter = adress_array_counter + 1

end

puts array_of_result_address.length

file_town_and_neighborhood = File.open("output_town_neighborhood.txt", "w")
file_town = File.open("output_town.txt", "w")
file_neighborhood = File.open("output_neighborhood.txt", "w")
file_nothing = File.open("output_nothing.txt", "w")

array_of_result_address.each do |result_address_object|

  object_status =  result_address_object.find_status

  if object_status == Status::FIND_NOTHING
    file_nothing.write(result_address_object.get_full_address + "\n")
    file_nothing.write("---------------------------\n")
  elsif object_status == Status::FIND_ONLY_TOWN
    file_town.write(result_address_object.get_full_address + "\n")
    file_town.write("Bulunan İlçe => " + result_address_object.get_town + "\n")
    file_town.write("---------------------------\n")
  elsif object_status == Status::FIND_ONLY_NEIGHBORHOOD
    file_neighborhood.write(result_address_object.get_full_address + "\n")
    file_neighborhood.write("Bulunan Mahalle => " + result_address_object.get_neighborhood + "\n")
    file_neighborhood.write("---------------------------\n")
  elsif object_status == Status::FIND_TOWN_AND_NEIGHBORHOOD
    file_town_and_neighborhood.write(result_address_object.get_full_address + "\n")
    file_town_and_neighborhood.write("Bulunan Mahalle => " + result_address_object.get_neighborhood + "\n")
    file_town_and_neighborhood.write("Bulunan İlçe => " + result_address_object.get_town + "\n")
    file_town_and_neighborhood.write("---------------------------\n")
  end

end

file_town.close
file_nothing.close
file_neighborhood.close
file_town_and_neighborhood.close

file_log = File.open("log.txt", "w")
file_log.write("Bulunan mahalle ve ilçeler " + ResultAdress.get_town_and_neighborhood_counter.to_s + " / " + ResultAdress.get_total_counter.to_s + "\n")
file_log.write("Sadece bulunan mahalleler " + ResultAdress.get_neighborhood_counter.to_s + " / " + ResultAdress.get_total_counter.to_s + "\n")
file_log.write("Sadece bulunan ilçeler " + ResultAdress.get_town_counter.to_s + " / " + ResultAdress.get_total_counter.to_s + "\n")
file_log.write("Bulunamayanlar " + ResultAdress.get_nothing_counter.to_s + " / " + ResultAdress.get_total_counter.to_s + "\n")

