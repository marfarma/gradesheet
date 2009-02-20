class Course < ActiveRecord::Base
	before_destroy :ensure_no_children

	belongs_to	:teacher
	belongs_to	:term, :counter_cache => true
	belongs_to	:grading_scale
	has_many		:assignments
	has_many		:enrollments
	has_many		:students, :through => :enrollments
	has_many		:gradations, :through => :assignments
	
	validates_existence_of :teacher, :message => "isn't a known teacher."
	validates_existence_of :term
	validates_existence_of :grading_scale
	
	validates_length_of		:name, :in => 1..20
	# FIXME
	#	validates_uniqueness_of :teacher, :scope => [:term, :course]

	# Courses are considered "active" only if they are in a grading term 
	# that is "active".
	named_scope :active, :conditions	=> "terms.active = 't'"


##
# Private Methods
##
private		

	# We don't want the user to delete a course term without first cleaning up
	# any assignments that use it.  This could cause a cascading effect wiping out
	# a whole year of student data.	
	def ensure_no_children
		unless self.assignments.empty?
			self.errors.add_to_base "You must remove all Assignments before deleting."
			raise ActiveRecord::Rollback
		end
	end



end
