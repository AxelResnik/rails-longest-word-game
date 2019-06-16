require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = Array.new(10) { ('A'..'Z').to_a.sample }
  end

  def score
    attempt = params[:word]
    grid = params[:grid]
    @result = {}
    if included?(attempt.upcase, grid)
      if english_word?(attempt)
        score = compute_score(attempt, params)
        @result[:score] = score
        @result[:message] = 'well done!'
      else
        @result[:score] = 0
        @result[:message] = "#{attempt} is not an english word"
      end
    else
      @result[:score] = 0
      @result[:message] = "#{attempt} is not in the grid #{grid}"
    end
  end

  private

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    json['found']
  end

  def included?(attempt, grid)
    attempt.chars.all? do |letter|
      attempt.count(letter) <= grid.count(letter)
    end
  end

  def compute_score(attempt, params)
    end_time = Time.now
    time_taken = (end_time.to_f - params[:start_time].to_f)
    word_lenght = attempt.size
    result = (word_lenght * 100) - time_taken / 100_000_000
    result.round
  end
end
