class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :trackable, :validatable

  has_many :games

  # find all users other than the current user
  scope :opponents, ->(user) { where.not(id: user) }

  # games played
  def games_played
    Game.where(['player_1_id = ? OR player_2_id = ?', self.id, self.id])
  end

  #total points
  def total_points
    total = 0
    self.games_played.each do |game|
      game.player_1_id == self.id ? total += game.player_1_score : total += game.player_2_score
    end
    return total
  end

  # games won by the user
  def games_won
    Game.where(['winner_id = ?', self.id])
  end

  # games lost by the user
  def games_lost
    Game.where(['player_1_id = ? OR player_2_id = ?', self.id, self.id]).where.not(['winner_id = ?', self.id])
  end

  # grab opponents for select
  def opponents
    User.opponents(id)
  end

  # Calculate expected results of game against opponent
  def expected_score_against(opponent)
   	return 1/(1+10**((opponent.rating - self.rating)/400.0))
  end

  # full name of the user
  def fullname
    "#{self.first_name} #{self.last_name}"
  end

  def self.reset_all_ratings
    self.update_all(rating: 1000)
  end

end
