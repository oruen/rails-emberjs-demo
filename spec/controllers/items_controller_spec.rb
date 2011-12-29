# encoding: utf-8
require 'spec_helper'

describe ItemsController do
  describe "index" do
    let!(:item1) { Item.create! :name => "name" }
    let!(:item2) { Item.create! :name => "name", :parent_id => item1.id }

    before do
      get :index, :format => "json"
      @items = JSON.parse(response.body)
    end

    it "ответ должен содержать элементы с parent_id == nil" do
      @items.map {|i| i["id"] }.should include(item1.id)
    end

    it "ответ не должен содержать элементы с parent_id != nil" do
      @items.map {|i| i["id"] }.should_not include(item2.id)
    end
  end
end
