# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#= require 'ember'
#= require 'sinon'
#= require 'ember-resource'

window.App = Em.Application.create()

App.Itemable = Em.Mixin.create({
  parent: (->
    self = this
    App.itemsController.find((item) ->
      item.get("id") == self.get("parent_id")
    )
  ).property("parent_id"),
  hasNoParent: (->
    Em.empty(@parent_id)
  ).property("parent_id"),
  escapedNameBinding: Em.Binding.transform(
    # HACK one of the underlying libs cant properly deal with quotes
    to: (value) -> return value.replace(/"/g, "'")
    from: (value) -> return (value && value.replace(/'/g, "\"") || value)
  ).from("name"),
  isDirty: false
})

App.Item = Em.Resource.define({
  url: '/items',
  schema: {
    id: Number,
    name: String,
    parent_id: Number,
    children: {
      type: Ember.ResourceCollection,
      itemType: "App.SubItem",
      nested: true
    }
  }
})

App.Item.reopen(App.Itemable)

App.SubItem = Em.Resource.define({
  url: '/items',
  schema: {
    id: Number,
    name: String,
    parent_id: Number
  }
})

App.SubItem.reopen(App.Itemable)

App.selectedItemController = Em.Object.create({
  content: null,
  hasErrors: false,
  contentDidChange: (->
    setTimeout((-> $("input[type='text']").focus()), 0)
  ).observes("content")
})

App.selectedItemView = Em.View.extend({
  contentBinding: "App.selectedItemController.content"
})

App.itemTextField = Em.TextField.extend({
  keyUp: ((event)->
    App.selectedItemController.content.set("isDirty", true)
    App.selectedItemController.set("hasErrors", false)
    return this._super(event);
  ),
  insertNewline: ->
    return false;
})

App.createItemView = Em.View.extend({
  mouseDown: ->
    App.itemsController.createItem()
})

App.createSubitemView = Em.View.extend({
  parentBinding: "App.selectedItemController.content",
  mouseDown: ->
    this.createItem(this.get("parent").get("children"), {parent_id: this.get("parent").get("id")})
  createItem: (collection, params) ->
    params = params || {}
    params.name = params.name || "New item"
    params.parent_id = params.parent_id || null
    item = App.SubItem.create(params)
    item.save().done(->
      collection.pushObject(item)
      App.selectedItemController.set("content", item)
    )
})

App.itemView = Em.View.extend({
  mouseDown: ->
    App.selectedItemController.set("content", @content)
})

App.saveItemView = Em.View.extend({
  mouseDown: ->
    cntr = App.selectedItemController
    item = cntr.content
    if (item.get("name").trim().length < 1)
      cntr.set("hasErrors", true)
    else
      item.save().done(->
        item.set("isDirty", false)
      )
})

App.deleteItemView = Em.View.extend({
  mouseDown: ->
    item = App.selectedItemController.content
    App.selectedItemController.set("content", null)
    if (item.get("parent"))
      item.get("parent").get("children").removeObject(item)
    else
      App.itemsController.removeObject(item)
    item.destroy()
})

App.SubItemsController = Em.ResourceCollection.extend({
  type: App.SubItem
})

App.itemsController = Em.ResourceCollection.create({
  type: App.Item,
  createItem: (params)->
    params = params || {}
    params.name = params.name || "New item"
    params.parent = params.parent || null
    params.parent_id = params.parent_id || null
    item = App.Item.create(params)
    item.set("children", App.SubItemsController.create({content: []}))
    self = this
    item.save().done(->
      self.pushObject(item)
      App.selectedItemController.set("content", item)
    )
})
