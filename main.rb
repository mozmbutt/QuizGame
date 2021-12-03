# frozen_string_literal: true

require 'csv'
require 'timeout'

# module for Welcome at Quiz Game
module Welcome
  def welcome_message
    puts '=' * 10
    puts 'Welcome to Quiz Game'
    puts '30 seconds default timeset for quiz.'
    puts 'Result will be published once quiz is over.'
    puts '=' * 10
  end
end

# class of Quiz
class Quiz
  include Welcome

  def initialize
    @questions = []
    @answers = []
    @user_answer = ''
    @correct_answer = ''
    @result = 0
    @timeout_session = 30
    @questions_asked = 0
  end

  attr_reader :read_answers, :read_questions, :read_user_answer, :read_timeout_session

  def read_result
    puts "Total questions were #{@questions.size}"
    puts "Total questions asked to you in #{@timeout_session} seconds were #{@questions_asked}"
    puts "You have scored #{@result} points"
  end

  def match_answers(index_to_match)
    @correct_answer = @answers[index_to_match]
    @user_answer = @user_answer.delete(' ').strip.to_i unless @user_answer.empty?
    @result = @result.next if @user_answer == @correct_answer.to_i
    puts '_' * 50
  end

  def table_empty?(table)
    if table.empty?
      puts '=' * 10
      puts 'There are no questions in file you have chosed !'
      puts '=' * 10
    end
  end

  def wait_for_user
    puts 'Press enter key to start the quiz !'
    gets
  end

  def load_quiz(file_name)
    table = CSV.parse(File.read(file_name))
    return if table_empty?(table)

    table = table.shuffle
    table.each do |row|
      @questions << row.first
      @answers << row.last
    end
    wait_for_user
  end

  def write_result(result)
    @result = result
  end

  def write_user_answer
    puts 'Write your answer: '
    @user_answer = gets.downcase.chomp.strip
  end

  def write_timeout_session(time)
    @timeout_session = time
  end

  def ask_question
    @questions.each_with_index do |question, index|
      @user_answer = ''
      puts "Question: #{question}"
      @questions_asked = @questions_asked.next
      write_user_answer
      match_answers(index)
    end
  end

  def start
    Timeout.timeout(@timeout_session) do
      ask_question
    end
  rescue Timeout::Error
    puts '=' * 10
    puts 'quiz time out'
    puts '=' * 10
  end
end

quiz = Quiz.new
quiz.welcome_message

puts 'Want to change default quiz time? (y/n)'
response = gets.downcase.chomp

if response == 'y'
  puts 'Enter new session time for quiz (in seconds)'
  time = gets.downcase.chomp.to_i
  quiz.write_timeout_session(time)
end

quiz.load_quiz('db.csv') # pass file name to read the file for questions and answers
quiz.start
quiz.read_result
