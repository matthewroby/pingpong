class GamesController < ApplicationController

  before_action :set_game, only: [:show, :edit, :update, :destroy]

  def new
    @user = current_user
    @game = current_user.games.new
  end

  def create
    @user = current_user
    @game = current_user.games.new(game_params)
    @game.player_1 = current_user

    if @game.save
      redirect_to history_path, notice: 'Game was successfully created.'
    else
      render :new
    end
  end

  private

    def game_params
      params.require(:game).permit(:played_at, :user_id, :player_1_id, :player_2_id, :player_1_score, :player_2_score, :winner_id)
    end

    def set_game
      @game = Game.find(params[:id])
    end

end
