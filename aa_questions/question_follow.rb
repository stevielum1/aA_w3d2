require_relative 'questions_database'
require_relative 'user'
require_relative 'question'

class QuestionFollow
  attr_accessor :question_id, :user_id
  
  def self.followers_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT users.*
      FROM users
      JOIN question_follows ON users.id = question_follows.user_id
      WHERE question_follows.question_id = ?
    SQL
    raise "QuestionFollow::followers_for_question_id is not in database" if data.length <= 0
    data.map { |datum| User.new(datum) }
  end
  
  def self.followed_questions_for_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT questions.*
      FROM questions
      JOIN question_follows ON questions.id = question_follows.question_id
      WHERE question_follows.user_id = ?
    SQL
    raise "QuestionFollow::followed_questions_for_user_id is not in database" if data.length <= 0
    data.map { |datum| Question.new(datum) }
  end
  
  def self.most_followed_questions(n)
    data = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT questions.*
      FROM questions
      JOIN question_follows ON questions.id = question_follows.question_id
      GROUP BY question_follows.question_id
      ORDER BY COUNT(*) DESC
      LIMIT ?
    SQL
    raise "QuestionFollow::most_followed_questions is not in database" if data.length <= 0
    data.map { |datum| Question.new(datum) }
  end
  
  def initialize(options)
    @question_id = options['question_id']
    @user_id = options['user_id']
  end
  
end