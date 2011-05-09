require 'digest'

class User < ActiveRecord::Base
  # Provides get/set methods
  attr_accessor :password

  # Ensures only these attributes can be set by update_attributes
  attr_accessible :name, :email, :password, :password_confirmation

	# Relationships with other models
	has_many :games_as_black, :foreign_key => "black_id", :class_name => "Game"
	has_many :games_as_white, :foreign_key => "white_id", :class_name => "Game"
	has_many :turns, :foreign_key => "turn_id", :class_name => "Game"
	has_many :moves

	def games
		games_as_black + games_as_white
	end

  # Email regex check
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  # Validations
  validates :name, 
    :presence => true,
    :length => { :maximum => 50 }
  validates :email,
    :presence => true,
    :format => { :with => email_regex },
    :uniqueness => { :case_sensitive => false }
  validates :password,
    :presence => true,
    :confirmation => true,
    :length => { :within => 6..40 }

  # Before saving changes to the database, encrypt the password
  before_save :encrypt_password

  # Check the users password
  def valid_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end

  # authenticate a user
  def self.authenticate(email, submitted_password)
    user = find_by_email(email)

    # return nil, if email didn't match
    return nil if user.nil?

    # returns nil if not valid_password otherwise, return user
    return user if user.valid_password?(submitted_password)
  end

  # authentication for cookies
  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)

    # Returns user if user is found & valid cookie, otherwise nil
    (user && user.salt == cookie_salt) ? user : nil
  end

	def find_match
		games = Game.find(:all, :conditions => ['black_id is NULL OR white_id is NULL'])

		game = games.find { | g | g.black != self && g.white != self }

		if game.nil?
			game = Game.new
			game.white = self
			game.turn = game.white
		else
			if game.white.nil?
				game.white = self
			end

			if game.black.nil?
				game.black = self
			end

			if game.turn.nil?
				if game.moves.count == 0
					game.turn = game.white
				else
					game.turn = game.black
				end
			end
		end

		return game
	end


  # Private methods
  private
    # Encrypts the users password
    def encrypt_password
      self.salt = make_salt if new_record?
      self.encrypted_password = encrypt(password)
    end

    # Makes a salt for the password
    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end

    # Encrypt a string w/ salt
    def encrypt(string)
      secure_hash("#{salt}--#{string}")
    end

    # Pass our salt+password to the encryption algorithm
    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end
end
