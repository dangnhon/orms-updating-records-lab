require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade, :id

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(id=nil, name, grade) 
    @name = name 
    @grade = grade 
    @id = id 
  end 

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    grade = row[2]
    new_student = Student.new(id, name, grade) 
    new_student
  end

  def save
    if self.id 
      self.update
    else 
    sql = "INSERT INTO students (name, grade) VALUES (?, ?)"
    DB[:conn].execute(sql, self.name, self.grade)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0] 
    end 
  end 

  def update
    sql = "UPDATE students SET name = ?, grade = ?"
    DB[:conn].execute(sql, self.name, self.grade)
  end


  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ?"
    DB[:conn].execute(sql, name).map{|row| self.new_from_db(row)}.first 
  end

  def self.create(name, grade) 
    student_list = Student.new(name, grade) 
    student_list.save
    student_list
  end 

end
