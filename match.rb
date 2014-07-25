class Event
	RANDOM_EVENT=[:one,:two,:three,:four,:five,:six,:no_ball,:wide,:out]
	RANDOM_EVENT_VALUE={:one =>1,:two=>2,:three=>3,:four=>4,:five=>5,:six=>6,:no_ball=>1,:wide=>1,:out=>0}
	def self.random_event
		RANDOM_EVENT[rand(0..8)]
	end

  RANDOM_EVENT.each do |method_name|
    define_method method_name do |*arg|
      case method_name
      when :one,:two,:three,:four,:five,:six
        arg.first.score=arg.first.score+RANDOM_EVENT_VALUE[method_name]
        team=Team.find_by_team_name(arg.first.team)
        team.score=team.score+RANDOM_EVENT_VALUE[method_name]
      when :no_ball,:wide
        team=Team.find_by_team_name(arg.first.team)
        team.score=team.score+RANDOM_EVENT_VALUE[method_name]
      when :out
        arg.first.status="out"
      end
    end
  end

end

class Ball
	def initialize(index,over)
		@over = over
		@index = index
		@event = nil
	end

	def over
		@over
	end
	def index
		@index
	end
end

class Over
	def initialize(over)
		@index = over
		@balls = (1..6).map{ |index| Ball.new(index,over)}
	end
	def balls
		@balls
	end
end

class Player
  attr_accessor :status,:score
  def initialize(index,team)
  	@index = index
    @team = team
    @points = 0
    @score=0
  end

  def score
    @score
  end

  def team
    @team
  end
end

class Team
	attr_accessor :status,:players,:score,:team_name
	def initialize(team)
		@team_name = team
		@players = (1..10).map{ |index| Player.new(index,team)}
		puts "Team #{team} Initilized"
		@score=0
		#@players.each{ |player| puts player.inspect }
	end

	def team_name
		@team_name
	end

  class << self
    [:status,:players,:score,:team_name].each do |method_name|
      define_method "find_by_#{method_name}" do |arg|
        objects=ObjectSpace.each_object(self).to_a
        objects.find {|team| team.send(method_name) == arg}
      end
    end
  end

	#def self.find_by_name(name)
  #data=ObjectSpace.each_object(self).to_a
  #puts data.find {|team| team.team_name == name}
	#end

	def players
		@players
	end

	def update_team_status(status)
		self.status=status
	end

end

class Match
	def initialize(team1, team2)
		@team_a = Team.new(team1)
		@team_b = Team.new(team2)
		@score_a = 0
		@score_b = 0
		puts "Match Initilized"
	end

	def teams
		teams = [@team_a,@team_b]
	end

	def fetch_player(team)
		team.players.find {|play| play.status==nil}
	end

	def fetch_bowler(team)
    team.players.sample
	end

	def toss
		puts "Toss"
		coin = rand(0..1)
		winner = coin == 0 ? @team_a : @team_b
		puts "Toss won by team #{winner.team_name}"
		winner
	end


	def start(batting,bowling)
		match_summary=[]
		@batting=batting
		@bowling=bowling
    @overs = (1..5).map{ |index| Over.new(index)}
    @overs.each do |over|
      blowing_player=fetch_bowler(@bowling).inspect
      runs=Hash.new()
      runs['over']=Hash.new()
      over.balls.each do |y|
        batting_player=fetch_player(@batting)
        event=Event.new
        event_name=Event.random_event
        runs['over']["#{y.over}.#{y.index}"]=event_name
        event.send(event_name,batting_player)
      end
      match_summary << runs
    end

    return @batting,match_summary
	end

	def batting_play
		self.teams.each do |p|
			@batting= p  if p.status=="Batting"
			@bowling= p  if p.status!="Batting"
		end
		self.start(@batting,@bowling)
	end

	def chasing_play
		self.teams.each do |p|
			@batting= p  if p.status!="Batting"
			@bowling= p  if p.status=="Batting"
		end
		self.start(@batting,@bowling)
	end

end


match = Match.new("A","B")
winning_team = match.toss
losing_team = match.teams.find{ |team| team.team_name != winning_team.team_name}
print "Batting or Bowling ? 0 for batting, 1 for bowling :  "
winner_input = gets.chomp.to_i
score = winner_input == 0 ? winning_team.update_team_status("Batting") : losing_team.update_team_status("Batting")
@score_a=match.batting_play[0].score
@score_b=match.chasing_play[0].score
puts "Match Summary"
puts summary_a=match.batting_play[1]
puts summary_b=match.chasing_play[1]
puts "_______________________"
winner= @score_a > @score_b ? "The winner team is #{match.batting_play[0].team_name} and score is #{@score_a}" : "The winner team is #{match.chasing_play[0].team_name} and score is #{@score_b}"
runner= @score_a < @score_b ? "The runner team is #{match.batting_play[0].team_name} and score is #{@score_a}" : "The runner team is #{match.chasing_play[0].team_name} and score is #{@score_b}"
puts "Congratulations #{winner}"
puts runner




