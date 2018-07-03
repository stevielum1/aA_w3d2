require_relative 'questions_database'
require_relative 'user'
require_relative 'question'

class Reply
  attr_accessor :id, :question_id, :parent_id, :user_id, :body
  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT *
      FROM replies
      WHERE replies.id = ?
    SQL
    raise "Reply::find_by_id is not in database" if data.length <= 0
    Reply.new(data.first)
  end
  
  def self.find_by_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT *
      FROM replies
      WHERE replies.user_id = ?
    SQL
    raise "Reply::find_by_user_id is not in database" if data.length <= 0
    data.map { |datum| Reply.new(datum) }
  end
  
  def self.find_by_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT *
      FROM replies
      WHERE replies.question_id = ?
    SQL
    raise "Reply::find_by_question_id is not in database" if data.length <= 0
    data.map {|datum| Reply.new(datum)}
  end
  
  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @parent_id = options['parent_id']
    @user_id = options['user_id']
    @body = options['body']
  end
  
  def author
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT *
      FROM users
      WHERE users.id = ?
    SQL
    raise "Reply#author is not in database" if data.length <= 0
    User.new(data.first)
  end
  
  def question
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT *
      FROM questions
      WHERE questions.id = ?
    SQL
    raise "Reply#question is not in database" if data.length <= 0
    Question.new(data.first)
  end
  
  def parent_reply
    data = QuestionsDatabase.instance.execute(<<-SQL, parent_id)
      SELECT *
      FROM replies
      WHERE replies.id = ?
    SQL
    raise "Reply#parent_reply is not in database" if data.length <= 0
    Reply.new(data.first)
  end
  
  def child_replies
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT *
      FROM replies
      WHERE replies.parent_id = ?
    SQL
    data.map { |datum| Reply.new(datum) }
  end
  
  def save
    if self.id
      QuestionsDatabase.instance.execute(<<-SQL, self.question_id, self.parent_id, self.user_id, self.body, self.id)
        UPDATE
          replies
        SET
          question_id = ?, parent_id = ?, user_id = ?, body = ?
        WHERE
          id = ?
      SQL
    else
      QuestionsDatabase.instance.execute(<<-SQL, self.question_id, self.parent_id, self.user_id, self.body)
        INSERT INTO
          replies(question_id, parent_id, user_id, body)
        VALUES
          (?, ?, ?,?)
      SQL
    end
    self.id = QuestionsDatabase.instance.last_insert_row_id
  end
  
  
end