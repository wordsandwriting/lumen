class Conversation
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :group, index: true  
    
  has_many :conversation_posts, :dependent => :destroy
  
  field :subject, :type => String
  field :slug, :type => Integer
  field :hidden, :type => Boolean, :default => false
  
  index({slug: 1 }, {unique: true})
  
  validates_presence_of :subject, :slug, :group
  validates_uniqueness_of :slug
  
  class Duplicate < StandardError; end
      
  def self.fields_for_index
    [:subject, :hidden, :slug, :group_id]
  end
  
  before_validation :set_slug
  def set_slug
    if !self.slug
      if Conversation.count > 0
        self.slug = Conversation.only(:slug).order_by(:slug.desc).first.slug + 1
      else
        self.slug = 1
      end
    end
  end
  
  before_validation :ensure_not_duplicate
  def ensure_not_duplicate    
    raise Duplicate if (most_recent = self.group.conversations.order_by(:created_at.desc).first) and self.subject == most_recent.subject
  end
  
  before_validation :hidden_to_boolean
  def hidden_to_boolean
    if self.hidden == '0'; self.hidden = false; elsif self.hidden == '1'; self.hidden = true; end; return true
  end  
  
  def self.fields_for_form
    {
      :subject => :text,
      :slug => :text,
      :hidden => :check_box,
      :group_id => :lookup,      
      :conversation_posts => :collection
    }
  end
  
  def self.lookup
    :subject
  end
  
  def last_conversation_post
    conversation_posts.order_by(:created_at.desc).first
  end
  
  def participants
    Account.where(:id.in => conversation_posts.where(:hidden.ne => true).map(&:account_id))
  end

end
