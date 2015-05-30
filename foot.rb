

Foot-Traffic Analysis

The world’s most prestigious art gallery in the world needs your help! Management wants to figure out how many people visit each room in the gallery, and for how long: this is to help improve the quality of the overall gallery in the future.

Your goal is to write a program that takes a formatted log file that describes the overall gallery’s foot-traffic on a minute-to-minute basis. From this data you must compute the average time spent in each room, and how many visitors there were in each room.

Input Description

You will be first given an integer N which represents the following N-number of lines of text. Each line represents either a visitor entering or leaving a room: it starts with an integer, representing a visitor’s unique identifier. Next on this line is another integer, representing the room index. Note that there are at most 100 rooms, starting at index 0, and at most 1,024 visitors, starting at index 0. Next is a single character, either ‘I’ (for “In”) for this visitor entering the room, or ‘O’ (for “out”) for the visitor leaving the room. Finally, at the end of this line, there is a time-stamp integer: it is an integer representing the minute the event occurred during the day. This integer will range from 0 to 1439 (inclusive). All of these elements are space-delimited.

You may assume that all input is logically well-formed: for each person entering a room, he or she will always leave it at some point in the future. A visitor will only be in one room at a time.

Note that the order of events in the log are not sorted in any way; it shouldn’t matter, as you can solve this problem without sorting given data. Your output (see details below) must besorted by room index, ascending.

Output Description

For each room that had log data associated with it, print the room index (starting at 0), then print the average length of time visitors have stayed as an integer (round down), andthen finally print the total number of visitors in the room. All of this should be on the same line and be space delimited; you may optionally include labels on this text, like in our sample output 1.

Sample Inputs & Outputs

Sample Input 1

4

0 0 I 540

1 0 I 540

0 0 O 560

1 0 O 560

Sample Output 1

Room 0, 20 minute average visit, 2 visitor(s) total

Sample Input 2

36

0 11 I 347

1 13 I 307

2 15 I 334

3 6 I 334

4 9 I 334

5 2 I 334

6 2 I 334

7 11 I 334

8 1 I 334

0 11 O 376

1 13 O 321

2 15 O 389

3 6 O 412

4 9 O 418

5 2 O 414

6 2 O 349

7 11 O 418

8 1 O 418

0 12 I 437

1 28 I 343

2 32 I 408

3 15 I 458

4 18 I 424

5 26 I 442

6 7 I 435

7 19 I 456

8 19 I 450

0 12 O 455

1 28 O 374

2 32 O 495

3 15 O 462

4 18 O 500

5 26 O 479

6 7 O 493

7 19 O 471

8 19 O 458

Sample Output 2

Room 1, 85 minute average visit, 1 visitor total

Room 2, 48 minute average visit, 2 visitors total

Room 6, 79 minute average visit, 1 visitor total

Room 7, 59 minute average visit, 1 visitor total

Room 9, 85 minute average visit, 1 visitor total

Room 11, 57 minute average visit, 2 visitors total

Room 12, 19 minute average visit, 1 visitor total

Room 13, 15 minute average visit, 1 visitor total

Room 15, 30 minute average visit, 2 visitors total

Room 18, 77 minute average visit, 1 visitor total

Room 19, 12 minute average visit, 2 visitors total

Room 26, 38 minute average visit, 1 visitor total

Room 28, 32 minute average visit, 1 visitor total

Room 32, 88 minute average visit, 1 visitor total

=====================================================================

Solution

class Base
attr_accessor :id
def initialize(arg)
@id = arg
end
def self.all
ObjectSpace.each_object(self).to_a
end
class <<self
[:id].each do |method_name|
define_method “find_or_create_by_#{method_name}” do |arg|
obj = self.all.find{|ob| ob.send(method_name).to_s == arg.to_s}
obj.nil? ? self.new(arg) : obj
end
end
end
end

class Visitor < Base
end

class Room < Base
end

class Period < Base
attr_accessor :visitor, :room, :time_in, :status, :time_out
def initialize(v,r,st,t_in)
@visitor = v.to_i
@room = r.to_i
@time_in = t_in.to_i
@status = st
end
def self.exit_period(v,r,st,t_out)
period = Period.all.find{ |p| p.visitor == v.to_i && p.room == r.to_i}
period.time_out = t_out.to_i
period.status = st
end
def self.job(inp)
inp = inp.split(” “)
visitor = Visitor.find_or_create_by_id(inp[0])
room = Room.find_or_create_by_id(inp[1])
case inp[2]
when “I”
Period.new(visitor.id,room.id,inp[2],inp[3])
when “O”
Period.exit_period(visitor.id,room.id,inp[2],inp[3])
else
puts “wrong input”
end
end

end

inp_cmd = “entry”
until inp_cmd == “exit”
inp_cmd = gets.chop
Period.job(inp_cmd) unless inp_cmd == “exit”
end

Room.all.sort_by{ |r| r.id.to_i}.each do |room|
p room.inspect
period = Period.all.find_all{ |p| p.room == room.id.to_i}
total_time = 0
period.each do |p|
time = p.time_out.to_i – p.time_in.to_i
total_time = total_time + time
end
p avg = total_time/period.count
end
