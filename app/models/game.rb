class Game < ActiveRecord::Base

  # primary creator of the game posting
  belongs_to :user

  # players (any valid user on the system with privs)
  belongs_to :player_1, class_name: 'User'
  belongs_to :player_2, class_name: 'User'

  # winner of the game
  belongs_to :winner, class_name: 'User'

  after_create :post_winner_of_game, :update_ratings_if_game_is_old

  validates_presence_of :user_id, :player_1_id, :player_2_id, :player_1_score, :player_2_score, :played_at
  validates_numericality_of(:player_1_score, :player_2_score, :in => 0..21)
  validate :has_winner, :has_different_players


  # always sort by played_at
  default_scope { order(played_at: :desc) }


  # custom validations
  def has_winner
    scores_arr = [player_1_score, player_2_score]
    has_winner = (scores_arr.first - scores_arr.last).abs >= 2 && scores_arr.any? {|s| s == 21}
    errors.add(:base, "A player must have reached 21 points with a 2 point difference for a Win") if !has_winner
    return has_winner
  end

  def has_different_players
    has_different_players = player_1_id != player_2_id
    errors.add(:base, "No player can play both sides!") if !has_different_players
    return has_different_players
  end



  # who won
  def winner_of_game
    self.player_1_score > self.player_2_score ? self.player_1_id : self.player_2_id
  end

  # who lost
  def loser_of_game
    self.player_1_score < self.player_2_score ? self.player_1_id : self.player_2_id
  end

  # offically post the winner via callback after create
  def post_winner_of_game
    self.update_attribute(:winner_id, self.winner_of_game)
  end

  # check to see if the game is newer than the last (by played_at) - if the first game, ignore and perform ELO
  def is_the_game_new
    if Game.count == 1
      true
    else
      self.played_at > Game.where.not(id: self.id).first.played_at
    end
  end

  # Update the ratings of all Users (if the game is older than latest by played_at) otherwise just the players
  def update_ratings_if_game_is_old
    self.is_the_game_new ? self.update_player_ratings : Game.update_all_player_ratings
  end

  # update the rankings of the players
  def update_player_ratings
    result = self.player_1 == self.winner_of_game ? 1 : 0
    player_1_new_rating = self.player_1.rating + (32*(result - self.player_1.expected_score_against(self.player_2)))
    player_2_new_rating = self.player_2.rating + (32*((1 - result) - self.player_2.expected_score_against(self.player_1)))

    self.player_1.update_attribute(:rating, player_1_new_rating)
    self.player_2.update_attribute(:rating, player_2_new_rating)
  end

  # rebuild all the User/player ratings from every game (and wrap in a transaction, just in case)
  def self.update_all_player_ratings
    ActiveRecord::Base.transaction do
      User.reset_all_ratings
      self.reorder('played_at asc').each do |game|
        game.update_player_ratings
      end
    end
  end


end
