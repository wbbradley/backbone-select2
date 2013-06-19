class BaseOptionView extends Backbone.View
  initialize: =>
    console.log 'OptionView init'
    if not @propertyValue
      throw new Error 'You must specify a propertyValue on a derived class from BaseOptionView'
    if not @propertyDisplay
      throw new Error 'You must specify a propertyName on a derived class from BaseOptionView'
    @listenTo @model, 'change', @render
  tagName: => 'option'
  render: =>

    @el.setAttribute 'value', _.result(@, 'propertyValue')
    @el.innerText = _.result(@, 'propertyDisplay')
    @

class TestOptionView extends BaseOptionView
  propertyValue: =>
    @model.cid
  propertyDisplay: =>
    @model.get('name') + ': ' + @model.get('age')

class SelectControlView extends Backbone.View
  format: (state) =>
    "#{state.name}"
  initialize: (options) =>
    @options = options
    if not @options?.selectedCollection?.model
      throw new Error 'SelectControlView : error : you must provide a collection to store the selected objects'
    @$select = @$el.select2
      multiple: true
      id: (item) ->
        item.id
      data:
        results: @collection.toJSON()
        text: 'name'
      formatResult: @format
      formatSelection: @format
      createSearchChoice: (term) =>
        itemsWithTerm = @collection.where {name: term}
        if itemsWithTerm?.length > 0
          return
        return {
          id: _.uniqueId 'n'
          name: term
          age: 18
        }
      placeholder: 'Choose'
    @$select.select2 'data', @options.selectedCollection.toJSON()
    @$select.change @onChange
    return

  onChange: (event) =>
    console.log "Select change event fired: added = #{event.added}; removed = #{event.removed}"
    if event.added
      itemMatching = @options.selectedCollection.findWhere {id: event.added.id}
      if itemMatching
        throw new Error 'SelectControlView : error : attempt to add item to selectedCollection that already exists'
      # TODO(will): call save on the new model?
      model = new @options.selectedCollection.model event.added
      @options.selectedCollection.add model
    if event.removed
      itemToRemove = @options.selectedCollection.findWhere {id: event.removed.id}
      if not itemToRemove
        throw new Error 'SelectControlView : error : change event occurred but selectedCollection is not in sync'
      @options.selectedCollection.remove itemToRemove
    return true

$ ->
  Handlebars.registerHelper 'dump', (obj) ->
    JSON.stringify(obj).toString()

  datapoints = new Backbone.Collection [
    {id: 1, name: 'Bill', age: 27}
    {id: 2, name: 'Alice', age: 28}
    {id: 3, name: 'John', age: 18}
    {id: 4, name: 'Mary', age: 58}
  ]

  selectedDatapoints = new Backbone.Collection [
    {id: 2, name: 'Alice', age: 28}
  ]

  selectView = new SelectControlView
    el: $('#sample-select')[0]
    collection: datapoints
    item_view_class: TestOptionView
    selectedCollection: selectedDatapoints

  class TestListView extends Guts.BasicModelView
    tagName: 'li'
    className: 'test-list-item'

  selectionView = new Guts.BaseCollectionView
    el: $('#selection-section')[0]
    item_view_class: TestListView
    collection: selectedDatapoints
