class Base
	def self.all
		return objects=ObjectSpace.each_object(self).to_a
	end
end

class Car < Base
  attr_accessor :number,:color,:slot
  def initialize(number,color,slot)
  	@number = number
    @color = color
    @slot=slot
  end

  class << self
    [:number,:color,:slot].each do |method_name|
      define_method "find_by_#{method_name}" do |arg|
        objects=ObjectSpace.each_object(self).to_a
        return objects.find {|team| team.send(method_name).to_s == arg.to_s}
      end
      define_method "find_all_by_#{method_name}" do |arg|
        objects=ObjectSpace.each_object(self).to_a
        return objects.find_all {|team| team.send(method_name).to_s == arg.to_s}
      end
    end
  end
end

class Slot < Base
  attr_accessor :status,:number
  def initialize(number,count)
  	@number = number
    @paking_total = count
    @status="free"
  end

  def number
    @number
  end

  #association
  def cars
       Car.all.find_all {|team| team.slot == self.number}
  end

  class << self
    [:status,:number].each do |method_name|
      define_method "find_by_#{method_name}" do |arg|
        objects=ObjectSpace.each_object(self).to_a
        return objects.find {|team| team.send(method_name).to_s == arg.to_s}
      end
    end
  end
end

class Parking < Base
	def initialize(count)
		@slot = (1..count).map{ |index| Slot.new(index,count)}
	end

	def fetch_slot
		@slot.find {|s| s.status=="free"}
  end

  def park(number,color)
    slot=self.fetch_slot
    if slot
      car=Car.new(number,color,slot.number)
      slot.status="full"
      puts "The Slot no provided is #{slot.number}"
    else
      puts "Sorry parking full"
    end
  end

  def leave(number,data=nil)
    slot=Slot.find_by_number(number)
    car=Car.find_by_slot(number)
    if slot && car
    slot.status="free"
    car.slot=""
    puts "The Slot no #{slot.number} is free"
    else
    puts "Sorry slot is not allocated to any car"
    end
  end
end



input_command = "entry"
until input_command=="exit"
  puts "Please provide your input"
  input_command = gets
  car_info=input_command.split(" ")
  case car_info[0]
  when "create_parking_lot"
    parking_lot = car_info[1].chomp.to_i
    parking =Parking.new(parking_lot)
  when "status"
    cars=Car.all
    puts "Slot No     Registration No    Colour"
    cars.each do |p|
    	puts "#{p.slot}     #{p.number}    #{p.color}"
    end
  when "registration_numbers_for_cars_with_colour"
    cars=Car.find_all_by_color(car_info[1])
    puts "Slot No     Registration No    Colour"
    cars.each do |p|
    	puts "#{p.slot}     #{p.number}    #{p.color}"
    end
  when "slot_numbers_for_cars_with_colour"
    cars=Car.find_all_by_color(car_info[1])
    puts "Slot No     Registration No    Colour"
    cars.each do |p|
    	puts "#{p.slot}     #{p.number}    #{p.color}"
    end
  when "slot_number_for_registration_number"
    cars=Car.find_all_by_number(car_info[1])
    puts "Slot No     Registration No    Colour"
    cars.each do |p|
    	puts "#{p.slot}     #{p.number}    #{p.color}"
    end
  when "park","leave"
    parking.send(car_info[0],car_info[1],car_info[2])
  else
    puts "Sorry Invalid Input"
  end
end
