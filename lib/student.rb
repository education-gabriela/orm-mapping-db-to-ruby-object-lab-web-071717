class Student
  attr_accessor :id, :name, :grade
  FIELDS = [:id, :name, :grade]

  def initialize
    @id = nil
    @name = nil
    @grade = nil
  end

  def save
    sql = <<-SQL
      INSERT INTO students (name, grade) 
      VALUES (?, ?)
    SQL

    DB[:conn].prepare(sql).execute(self.name, self.grade)
  end

  def self.new_from_db(row)
    student = self.new

    Hash[row.map.with_index {|column_value, i|
      # [FIELDS[i], column_value]
      student.send("#{FIELDS[i]}=", column_value)
    }]

    student
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students WHERE name = ? LIMIT 1
    SQL

    result = DB[:conn].execute(sql, name)
    self.new_from_db(result.first)
  end

  def self.count_all_students_in_grade_9
    self.find_by_grade(9)
  end

  def self.students_below_12th_grade
    sql = <<-SQL
      SELECT * FROM students WHERE grade <= ? LIMIT 1
    SQL

    DB[:conn].execute(sql, "12")
  end

  def self.first_x_students_in_grade_10(limit)
    self.find_by_grade(10, limit)
  end

  def self.first_student_in_grade_10
    self.find_by_grade(10).first
  end

  def self.all_students_in_grade_x(grade)
    self.find_by_grade(grade, "all")
  end

  def self.find_by_grade(grade, limit = 1)
    sql = "SELECT * FROM students WHERE grade = ?"

    if limit != "all"
      sql += " LIMIT ?"
      result = DB[:conn].execute(sql, grade, limit)
    else
      result = DB[:conn].execute(sql, grade)
    end

    self.db_collection_to_instance(result)
  end

  def self.db_collection_to_instance(result)
    result.collect do |row|
      self.new_from_db(row)
    end
  end

  def self.all
    result = DB[:conn].execute("SELECT * FROM students")
    self.db_collection_to_instance(result)
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].prepare(sql).execute
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].prepare(sql).execute
  end
end
