# encoding: utf-8
class Item < ActiveRecord::Base
  validates :name, :presence => true
  has_many :children, :class_name => "Item", :foreign_key => "parent_id", :dependent => :destroy
  belongs_to :parent, :class_name => "Item", :foreign_key => "parent_id"

  def as_json(options={})
    super(options.merge(:include => :children))
  end
end
