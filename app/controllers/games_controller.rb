class GamesController < ApplicationController
  def new
    @letters = Array.new(10) { ("A".."Z").to_a.sample }
    @starttime = Time.now
  end

  def score
    @grid = params[:grid]
    @word = params[:word]
    @start_time = Time.parse(params[:starttime])
    @end_time = Time.now
    @result = run_game(@word, @grid.chars, @start_time, @end_time)
  end

  # old code
  def run_game(attempt, grid, start_time, end_time)
    elapsed_time = (end_time - start_time).round(2)
    return { time: elapsed_time, score: 0, message: "Longer" } if attempt.length > grid.length
    return { time: elapsed_time, score: 0, message: "Not in the grid" } unless in_grid?(attempt, grid)
    return { time: elapsed_time, score: 0, message: "Not an English word" } unless found_in_api?(attempt)

    score = calculate_score(attempt, elapsed_time)
    { time: elapsed_time, score: score, message: "<strong>Well Done!</strong>" }
  end

  def in_grid?(attempt, grid)
    attempt_chars = attempt.upcase.chars
    grid_chars = grid.dup

    attempt_chars.all? do |char|
      if grid_chars.include?(char)
        grid_chars.delete_at(grid_chars.index(char))
        true
      else
        false
      end
    end
  end

  def found_in_api?(attempt)
    user = JSON.parse(URI.parse("https://dictionary.lewagon.com/#{attempt.downcase}").read)
    user["found"]
  end

  def calculate_score(word, time)
    (word.length.to_f / time * 10).round(2)
  end

end
