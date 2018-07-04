require_relative 'questions_database'
require_relative 'user'
require_relative 'reply'
require_relative 'question_follow'
require_relative 'question_like'
require_relative 'model_base'

class Question < ModelBase
  attr_accessor :id, :body, :title, :author_id
  
  def self.find_by_author_id(author_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT *
      FROM questions
      WHERE questions.author_id = ?
    SQL
    raise "Question::find_by_author_id is not in database" if data.length <= 0
    data.map { |datum| Question.new(datum) }
  end
  
  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end
  
  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end
  
  def initialize(options)
    @id = options['id']
    @body = options['body']
    @title = options['title']
    @author_id = options['author_id']
  end
  
  def author
    data = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT *
      FROM users
      WHERE users.id = ?
    SQL
    raise "Question#author is not in database" if data.length <= 0
    User.new(data.first)
  end
  
  def replies
    Reply.find_by_question_id(self.id)
  end
  
  def followers
    QuestionFollow.followers_for_question_id(self.id)
  end
  
  def likers
    QuestionLike.likers_for_question_id(self.id)
  end
  
  def num_likes
    QuestionLike.num_likes_for_question_id(self.id)
  end
  
  def save
    if self.id
      QuestionsDatabase.instance.execute(<<-SQL, self.body, self.title, self.author_id, self.id)
        UPDATE
          questions
        SET
          body = ?, title = ?, author_id = ?
        WHERE
          id = ?
      SQL
    else
      QuestionsDatabase.instance.execute(<<-SQL, self.body, self.title, self.author_id)
        INSERT INTO
          questions(body, title, author_id)
        VALUES
          (?, ?, ?)
      SQL
      self.id = QuestionsDatabase.instance.last_insert_row_id
    end
  end
  
end