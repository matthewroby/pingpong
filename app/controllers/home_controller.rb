class HomeController < ApplicationController

  def index
    @users = User.order(rating: :desc)
  end

  def history
    @user = current_user
    @games = current_user.games_played
  end

  def log
    # nothing to do here.
  end


end
