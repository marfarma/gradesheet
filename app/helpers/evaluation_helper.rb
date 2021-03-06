module EvaluationHelper

  #  Build the body of the skills evaluation table
  def skills_body
    number_of_students = @course_term.course.students.size
    counter = 0
    body = ""

    body += "<tr><td>No Students Found</td></tr>" if number_of_students == 0

    # Process each student
    students = @course_term.course.students.sort_by {|a| a.last_name }
    students.each do |student|
      #  Set up the row for this student
      body += "<tr class='calc #{cycle('odd','even')}' id='#{student.id}'>"
      body += content_tag :td, student.full_name, :id => student.id
      a_counter = counter + 1
      
      # Build the table and form entries for each skill for this student
      @course_term.course_term_skills.each do |ctskill|
        body += "<td class = 'skills'>"
        
        body += text_field_tag 'score', ctskill.score(student.id),
          :name		=> 'skill',
          :id			=> [:s => student.id, :a => ctskill.id],
          :tabindex	=> a_counter,
          :onchange => remote_function( :url => {:action => "update"}, :method => "put",
          :with   => "'student=#{student.id}&skill=#{ctskill.id}&score=' + value",
          :loading => "Element.show('spinner')",
          :complete => "Element.hide('spinner')"),
          :size		=> '5'

        body += "</td>"
        a_counter += number_of_students
      end
      body += "</tr>"
      counter += 1
    end

    return body
  end
end