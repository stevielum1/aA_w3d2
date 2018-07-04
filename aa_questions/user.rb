require_relative 'questions_database'
require_relative 'question'
require_relative 'reply'
require_relative 'question_follow'
require_relative 'question_like'
require_relative 'model_base'

class User < ModelBase
  attr_accessor :id, :fname, :lname
  
  def self.find_by_name(fname, lname)
    data = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT *
      FROM users
      WHERE users.fname = ? AND users.lname = ?
    SQL
    raise "User::find_by_name is not in database" if data.length <= 0
    User.new(data.first)
  end
  
  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end
  
  def authored_questions
    Question.find_by_author_id(self.id)
  end
  
  def authored_replies
    Reply.find_by_user_id(self.id)
  end
  
  def followed_questions
    QuestionFollow.followed_questions_for_user_id(self.id)
  end
  
  def liked_questions
    QuestionLike.liked_questions_for_user_id(self.id)
  end
  
  def average_karma
    data = QuestionsDatabase.instance.execute(<<-SQL, self.id)
      SELECT CAST(COUNT(question_likes.user_id) AS FLOAT)/COUNT(DISTINCT questions.id) AS average_karma
      FROM questions
      LEFT OUTER JOIN question_likes ON questions.id = question_likes.question_id
      WHERE questions.author_id = ?;
    SQL
    data.first["average_karma"]
  end
  
  # def save
  #   if self.id
  #     QuestionsDatabase.instance.execute(<<-SQL, self.fname, self.lname, self.id)
  #       UPDATE
  #         users
  #       SET
  #         fname = ?, lname = ?
  #       WHERE
  #         id = ?
  #     SQL
  #   else
  #     QuestionsDatabase.instance.execute(<<-SQL, self.fname, self.lname)
  #       INSERT INTO
  #         users(fname, lname)
  #       VALUES
  #         (?, ?)
  #     SQL
  #     self.id = QuestionsDatabase.instance.last_insert_row_id
  #   end
  # end
end