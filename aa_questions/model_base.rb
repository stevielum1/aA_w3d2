require_relative 'questions_database'

class ModelBase
  
  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id )
      SELECT *
      FROM #{table}
      WHERE id = ?
    SQL
    raise "#{self}::find_by_id is not in database" if data.length <= 0
    self.new(data.first)
  end
  
  def self.all
    data = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT *
      FROM #{table}
    SQL
    data.map { |datum| self.new(datum) }
  end
  
  def self.table
    table_name = self.to_s.downcase
    if table_name[-1] == "y"
      table_name = table_name[0..-2] + "ies"
    else
      table_name += "s"
    end
  end

  def save
    instance_variables = self.instance_variables
    id = instance_variables.shift
    if self.id
      instance_variables.each do |instance_variable|
        QuestionsDatabase.instance.execute(<<-SQL, instance_variable, self.instance_variable, self.id)
          UPDATE
            #{table}
          SET
            ? = ?
          WHERE
            id = ?
        SQL
      end
    else
      QuestionsDatabase.instance.execute(<<-SQL, instance_variables)
        INSERT INTO
          #{table}#{generate_into}
        VALUES
          #{generate_values}
      SQL
      self.id = QuestionsDatabase.instance.last_insert_row_id
    end
  end

  def generate_into
    result = "("
    instance_variables = self.instance_variables
    instance_variables.shift
    instance_variables.map! { |instance_variable| instance_variable.to_s.delete("@") }
    result += instance_variables.join(", ")
    result += ")"
  end
  
  def generate_values
    result = ""
    instance_variables = self.instance_variables
    instance_variables.shift
    instance_variables.length.times { |i| result << "?" }
    result = result.split("").join(", ")
    result = "(" + result + ")"
  end
  
  
end