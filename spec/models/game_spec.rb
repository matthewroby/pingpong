require 'rails_helper'

RSpec.describe Game, :type => :model do

  fixtures :games

  subject { described_class.new }

  describe "should be associated to User, Player1 and Player2" do
    it { should belong_to(:user) }
    it { should belong_to(:player_1) }
    it { should belong_to(:player_2) }
  end

  it "should have params to be valid" do
    expect(subject).to_not be_valid
  end

  it "should not be valid unless either player 21 points" do
    subject.user_id = 1
    subject.player_1_id = 1
    subject.player_2_id = 2
    subject.player_1_score = 12
    subject.played_at = Time.now
    # > 21
    subject.player_2_score = 22
    expect(subject).to_not be_valid
    # < 21
    subject.player_2_score = 20
    expect(subject).to_not be_valid
    subject.player_2_score = 21
    expect(subject).to be_valid
  end

  it "should not be valid with less than a 2 point difference" do
    subject.user_id = 1
    subject.player_1_id = 1
    subject.player_2_id = 2
    subject.player_1_score = 20
    subject.player_2_score = 21
    subject.played_at = Time.now
    expect(subject).to_not be_valid
  end

  it "should be valid when the game reaches 21 points AND there is a minimum 2 point difference" do
    subject.user_id = 1
    subject.player_1_id = 1
    subject.player_2_id = 2
    subject.player_1_score = 18
    subject.player_2_score = 21
    subject.played_at = Time.now
    expect(subject).to be_valid
  end

  it "should not be valid when player 1 is the same as player 2" do
    subject.user_id = 1
    subject.player_1_id = 1
    subject.player_2_id = 1
    subject.player_1_score = 18
    subject.player_2_score = 21
    subject.played_at = Time.now
    expect(subject).to_not be_valid
  end

  it "should select the correct players as winner and loser" do
    subject.user_id = 1
    subject.player_1_id = 1
    subject.player_2_id = 2
    subject.player_1_score = 12
    subject.player_2_score = 21
    subject.played_at = Time.now
    expect(subject.winner_of_game).to be 2
    expect(subject.loser_of_game).to be 1
  end

  it "can detect if the same player was entered on both sides" do
    subject.user_id = 1
    subject.player_1_id = 1
    subject.player_2_id = 1
    subject.player_1_score = 18
    subject.player_2_score = 21
    subject.played_at = Time.now
    expect(subject.has_different_players).to be false
    subject.player_2_id = 2
    expect(subject.has_different_players).to be true
  end

  it "should fetch the correct record" do
    @game = Game.find(3)
    expect(@game.user_id == 3 && @game.player_1_id == 1 && @game.player_2_id == 2 && @game.player_1_score == 21 && @game.player_2_score == 12 && @game.winner_id == 1).to be true
  end

  it "should by default return records in reverse chronological order on played_at" do
    expect(Game.first.played_at).to be > Game.last.played_at
  end

end
