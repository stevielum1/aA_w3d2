require_relative 'questions_database'
require_relative 'user'
require_relative 'question'

class QuestionLike
  attr_accessor :user_id, :question_id

  def self.likers_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT users.*
    FROM questions
    JOIN question_likes ON questions.id = question_likes.question_id
    JOIN users ON users.id = question_likes.user_id
    WHERE question_likes.question_id = ?
    SQL
    data.map { |datum| User.new(datum) }
  end
  
  def self.num_likes_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT COUNT(*)
    FROM questions
    JOIN question_likes ON questions.id = question_likes.question_id
    JOIN users ON users.id = question_likes.user_id
    WHERE question_likes.question_id = ?
    GROUP BY question_likes.question_id
    SQL
    data.first["COUNT(*)"]
  end
  
  def self.liked_questions_for_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT questions.*
    FROM questions
    JOIN question_likes ON questions.id = question_likes.question_id
    JOIN users ON users.id = question_likes.user_id
    WHERE question_likes.user_id = ?
    SQL
    data.map { |datum| Question.new(datum) }
  end
  
  def self.most_liked_questions(n)
    data = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT questions.*
      FROM questions
      JOIN question_likes ON questions.id = question_likes.question_id
      GROUP BY question_likes.question_id
      ORDER BY COUNT(*) DESC
      LIMIT ?
    SQL
    raise "QuestionLike::most_liked_questions is not in database" if data.length <= 0
    data.map { |datum| Question.new(datum) }
  end
  
  def initialize(options)
    @question_id = options['question_id']
    @user_id = options['user_id']
  end
  
end