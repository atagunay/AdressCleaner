require 'turkish_support'
require 'set'

class CanSpeakInTurkish
  using TurkishSupport
  
  def down(string)
    string.downcase
  end
end

def readFileAndConvertArray(file_name)
  set = Set.new

  file = File.open(file_name)
  file_data = file.readlines.map(&:chomp)
  file_data.each do |item|
    set.add(CanSpeakInTurkish.new.down(item))
  end

  file.close
  return set.to_a
end

ilce_array = readFileAndConvertArray("ilce.txt")
mahalle_array = readFileAndConvertArray("mahalle.txt")
address_array = readFileAndConvertArray("adress.txt")

i = 0

while i < address_array.length
  puts address_array[i]

  str = address_array[i].split(" ")

  j = 0
  while j < str.length

    if str[j].length == 5 and str[j].include? "34"
      puts str[j]
    end

    ilce_array.each do |town|
      if str[j].include? town
        puts "Bulunan İlçe " + str[j] + " - " + "Eşleşen item:" + town
      end
    end

    if mahalle_array.each do |neighborhood|
      if str[j] == neighborhood and str[j+1] != nil and str[j+1].include? "mah"
        puts "Bulunan Mahalle " +  str[j] + " - " + "Eşleşen item:" + neighborhood
      end
    end
    end
    j = j + 1
  end


  puts "---------------------------"

  i = i + 1
end
