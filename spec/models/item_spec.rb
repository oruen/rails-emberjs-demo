# encoding: utf-8
require 'spec_helper'

describe Item do
  it "должен иметь дочерние item'ы" do
    item1 = Item.create! :name => "item1"
    item2 = Item.create! :name => "item2"

    item1.children << item2

    item2.parent.should == item1
    item1.reload.children.should include(item2)
  end

  it "должен сериализироваться в json вместе с детьми" do
    item1 = Item.create! :name => "item1"
    item2 = Item.create! :name => "item2"

    item1.children << item2

    item1.as_json[:children].should have(1).item
    %w(id parent_id name).each do |attr|
      item1.as_json[:children].first[attr].should == item2.send(attr)
    end
  end
end
