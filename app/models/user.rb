require 'digest/sha1'

class User < ActiveRecord::Base
  has_and_belongs_to_many :projects
  attr_accessible :username, :first_name, :last_name, :email
  
  attr_accessor :password

  # If this is used elsewhere, put it in config/initializers/constants.rb
  EMAIL_REGEX = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i

  validates :first_name, :presence => true, :length => { :maximum => 25 }
  validates :last_name, :presence => true, :length => { :maximum => 50 }
  validates :username, :presence => true, :length => { :within => 3..25 }, :uniqueness => true
  validates :email, :presence => true, :length => { :maximum => 100 }, :format => EMAIL_REGEX, :confirmation => true

  # only on creation, so other attributes of this user can be changed
  validates_length_of :password, :within => 8..25, :on => :create

  # callbacks
  before_save :create_hashed_password
  after_save :clear_password
  
  scope :named, lambda {|first,last| where(:first_name => first, :last_name => last)}
  scope :sorted, :order => "last_name ASC, first_name ASC"

  attr_protected :hashed_password, :salt
  
  def self.make_salt(username="")
  	Digest::SHA1.hexdigest("Use #{username} with #{Time.now} to make salt")
  end
  
  def self.hash_with_salt(password="", salt="")
  	Digest::SHA1.hexdigest("Put #{salt} on the #{password}")
  end
  
  def self.authenticate(username="", password="")
  	# 1. query for username
  	user = User.where(:username => username).first
  	# could also use find_by_username
  	
  	return false if user == nil
	# 2 if found, encrypt and compare passwords
	hashed_password = User.hash_with_salt(password,user.salt)
	return false if hashed_password != user.hashed_password
	return user
  end
  
  def name
  	first_name + ' ' + last_name
  end
  
  private #everything below here callable only by class
  
  def create_hashed_password
  	# whenever :password has a value hashing is needed
  	unless password.blank?
  		# always use self when assigning values
  		self.salt = User.make_salt(username) if salt.blank? # make the salt if we don't have it
  		self.hashed_password = User.hash_with_salt(password, salt)
  	end
  end

  def clear_password
  	self.password = nil
  end
  
end
