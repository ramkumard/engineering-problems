require 'time'
class Base
  def self.all
    return objects=ObjectSpace.each_object(self).to_a
  end
end

class Session < Base
  attr_accessor :session_number,:start_time,:end_time,:status,:type,:total_time,:current_time
  def initialize(session_number,start_time,end_time,type)
  	@session_number =session_number
    @start_time = DateTime.new(2014, 02, 24,start_time,0,0).strftime("%I:%M%p")
    @end_time = DateTime.new(2014, 02, 24,end_time,0,0).strftime("%I:%M%p")
    @total_time=((DateTime.new(2014, 02, 24,end_time,0,0) - DateTime.new(2014, 02, 24,start_time,0,0)) * 24 * 60 ).to_i
    @status="free"
    @current_time =0
    @type =type
  end
end

class Talk < Base
  attr_accessor :name,:time,:status
  def initialize(name,time)
  	@name =name
    @time = time=="lightning" ? 5.to_i : time.gsub("min","").to_i
    @status="unassigned"
  end

  def self.get_unassigned_talk
  	self.all.find_all {|talk| talk.status == "unassigned"}
  end

  def self.compute_total_time
  	self.all.map(&:time).inject(:+)
  end
end

class Track < Base
  attr_accessor :id,:status,:session,:track_time
  @@intialize_id = 0
  def initialize()
    @session=[]
    @@intialize_id+=1
    @id = @@intialize_id
    @status="free"
    @track_time = 0
    @session << Session.new(1,9,12,"morning")
    @session << Session.new(2,13,17,"afternoon")
  end
  def sessions
  	@session
  end
end

class Event < Base
  attr_accessor :session_number,:track_id,:talk_name,:start_time,:end_time
  def initialize(session_number,track_id,talk_name,start_time,end_time)
  	@session_number =session_number
    @track_id =track_id
    @talk_name =talk_name
    @start_time =start_time
    @end_time =end_time
  end
end

class Conference < Base
 attr_accessor :id, :total_time, :tracks
	@@intialize_id = 0
	def initialize
		@@intialize_id+=1
		@id = @@intialize_id
		@total_time = 0
		@tracks = []
	end
end

#@con=Conference.new()
input_command = "entry"
until input_command=="exit"
  input_command = gets
  Talk.new(input_command.split(" ")[0..input_command.split(" ").count-2].join(" "),input_command.split(" ").last) unless input_command=="exit"
end

total_time = Talk.compute_total_time
conference = Conference.new()
final_list=[]
until conference.total_time == total_time
	track = Track.new()
	track.sessions.each do |session|
		Talk.get_unassigned_talk.each do |talk|
			temp = session.current_time + talk.time
			if temp < session.total_time 
				start_time =session.session_number==1 ? Time.at(session.start_time.to_i*60*60+session.current_time*60).utc.strftime("%I:%M%p") : Time.at((session.start_time.to_i+12)*60*60+session.current_time*60).utc.strftime("%I:%M%p")
				end_time= session.session_number==1 ? Time.at(session.start_time.to_i*60*60+temp*60).utc.strftime("%I:%M%p") : Time.at((session.start_time.to_i+12)*60*60+temp*60).utc.strftime("%I:%M%p")
				final_list<< Event.new(session.session_number,track.id,talk.name,start_time,end_time)
				session.current_time += talk.time
				talk.status="assigned"        
			end
		end
		track.track_time += session.current_time
	end
conference.tracks << track
conference.total_time +=track.track_time
end


final_list.each do |track|
  puts "\t \t day#{track.track_id} #{track.start_time}  #{track.talk_name}  #{track.end_time} \n"
end