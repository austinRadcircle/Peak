class Post < ActiveRecord::Base
	validates :title, presence: true
	validates :body, presence: true
    
  
  	
  	belongs_to :user
  	belongs_to :song
  	has_many :posts

	def to_s
		"#{title}"
	end

	def self.search(query)
		where("title like ?", "%#{query}%")
	end

	def to_param
		"#{id}-#{slug}"
	end

	def slug
		title.downcase.gsub(" ", "-")
	end

end
