# Contains the information about the User archtype.  This class is not used
# directly but subclassed for other user types (Teacher, Student, etc.) 
class User < ActiveRecord::Base
  # Authlogic setup
  acts_as_authentic do |c|
    # Set the timeout to something workable while in development
    c.logged_in_timeout = (RAILS_ENV == 'development' ? 1000.minutes : 10.minutes)
    
    # Turn off the email validation as some students/teachers might not have an address.
    c.validate_email_field = false
  end
  
  belongs_to	:site
#	has_many		:comments

	validates_length_of			:first_name, :in => 1..20
	validates_length_of			:last_name, :in => 1..20
	validates_existence_of 	:site

  # Users should be unique, so don't allow a user with the same First & Last Name
  # in the system.
	validates_uniqueness_of	:first_name, :scope => :last_name

	# Search for a user using the 'will_paginate' plugin
	def self.search(params)
    search = params[:search]
		search.downcase! if search	# Make sure we don't have any case sensitivity problems
		paginate	:per_page => 15, :page => params[:page],
							:conditions => ['LOWER(first_name) like ? or LOWER(last_name) like ?', "%#{search}%", "%#{search}%"], 
							:order => params[:sort_clause],
							:include => :site
	end
	
	# Return the valid user types available to be instaciated.
	# FIXME: I'm sure there is a better way to do this, but I didn't know how at the time.
	def self.find_user_types(*args)
		return {
		    'ALL'       => Users, 
		    'Teachers'  => Teacher, 
		    'Students'  => Student, 
		    'Teacher Assistants' => TeacherAssistant}
	end

	# Convienience method to display the users full name.
	def full_name
		[first_name, last_name].join(' ')
	end
	
	# Convieniene method to break a users full name into its components
	def full_name=(name)
		split = name.split(' ', 2)
		self.first_name = split.first
		self.last_name = split.last
	end

end
