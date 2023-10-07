class GamesController < ApplicationController
  require 'open-uri'
  require 'json'

  def new
    @letters = ('A'..'Z').to_a
    @display_grid = @letters.shuffle.take(10)

    session[:start_time] = Time.now
  end

  def score
    grid = params[:grid]
    attempt = params[:play]

    score, message = score_and_message(attempt, grid)

    @result = { score: score, message: message }

    render 'score'
  end

  private

  def score_and_message(attempt, grid)
    if attempt.blank?
      [0, "Please enter a word."]
    elsif !english_word?(attempt)
      [0, "The word is not a valid English word."]
    elsif !included?(attempt.upcase, grid)
      [0, "The word cannot be built from the original grid letters."]
    else
      score = compute_score(attempt)
      [score, "Well done! You scored #{score} points."]
    end
  end

  def compute_score(attempt)
    base_score = attempt.length
    max_score = 10
    time_limit = 60.0

    start_time = session[:start_time]
    current_time = Time.now
 

    if start_time.is_a?(Time)
      time_taken = current_time - start_time


      score = if time_taken <= time_limit
                 (base_score * (1.0 - time_taken / time_limit) * max_score).to_i
               else
                 0
               end

      score
    else
      0
    end
  end





  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def english_word?(word)
    response = URI.open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    json['found']
  end
end
