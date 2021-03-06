require File.dirname(__FILE__) + '/../test_helper'

class SiteTest < ActiveSupport::TestCase
	def setup
    @site = Site.new :name => 'Test Site'
    assert @site.save, "Initial site was saved"
	end

	def teardown
		assert @site.destroy
	end

	def test_site_name_length
		@site.name = 'This is a really long site name that probably shouldn\'t be legal because it is too long'
  	assert !@site.valid?, 'Site name too long' 	

		@site.name = ''
	 	assert !@site.valid?, 'Site name too short' 	

		@site.name = 'Site #2'
		assert @site.valid?, 'Site name is just right'		
  end

  def test_site_cannot_have_duplicates
    dup_site = Site.create( :name => @site.name.upcase )
    assert !dup_site.save, 'Duplicate Site is not valid'

    dup_site = Site.create( :name => @site.name.downcase )
    assert !dup_site.save, 'Duplicate Site is not valid'
  end
  
  def test_site_cannot_be_deleted_if_being_used
    # Get some existing user
    my_user = User.first
    assert my_user.valid?, "user is valid"

    # Store the old data
    old_site = my_user.site
    assert_equal old_site, my_user.site, "duplicated site data"
    
    # Bind the user to the site
    my_site = @site
    assert my_site.valid?, "Temp site is valid"        
    my_user.site = my_site
    assert my_user.save, "Saved user with temp site"
    
    # Try to delete the site
    assert !my_site.destroy, 'Can\'t destroy a Site that is in use'
    
    # Reset the user data
    assert my_user.site = old_site
    assert my_user.save, "Saved user with old site"
    
    # Try to delete the site again
    assert my_site.destroy, 'Delete unused Site'
  end
end
