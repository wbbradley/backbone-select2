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

class MultiSelectControlView extends Backbone.View
  formatter: =>
    if typeof @options.displayProperty is 'string'
      displayProperty = @options.displayProperty
      (item) ->
        _.result item, displayProperty
    else
      throw new Error 'MultiSelectControlView : error : you must define the displayProperty in your model to show in the dropdown'

  initialize: (options) =>
    @options = options
    if not @options?.selectedCollection?.model
      throw new Error 'MultiSelectControlView : error : you must provide a collection to store the selected objects'
    @$select = @$el.select2
      multiple: true
      id: do =>
        id = @options.id
        (item) ->
          _.result item, id or 'id'
      data:
        results: @collection.toJSON()
        text: @options.displayProperty
      formatResult: @formatter()
      formatSelection: @formatter()
      createSearchChoice: (term) =>
        search = {}
        search[@options.displayProperty] = term
        itemsWithTerm = @collection.where search
        if itemsWithTerm?.length > 0
          return
        searchChoice = _.extend {}, @options.defaultItem, id: _.uniqueId 'n'
        searchChoice[@options.displayProperty] = term
        return searchChoice
      placeholder: @options.placeholder
    @$select.select2 'data', @options.selectedCollection.toJSON()
    @$select.change @onChange
    return

  onChange: (event) =>
    console.log "Select change event fired: added = #{event.added}; removed = #{event.removed}"
    if event.added
      itemMatching = @options.selectedCollection.findWhere {id: event.added.id}
      if itemMatching
        throw new Error 'MultiSelectControlView : error : attempt to add item to selectedCollection that already exists'
      # TODO(will): call save on the new model?
      model = new @options.selectedCollection.model event.added
      @options.selectedCollection.add model
    if event.removed
      itemToRemove = @options.selectedCollection.findWhere {id: event.removed.id}
      if not itemToRemove
        throw new Error 'MultiSelectControlView : error : change event occurred but selectedCollection is not in sync'
      @options.selectedCollection.remove itemToRemove

testBackboneSelect2 = ->
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

  selectView = new MultiSelectControlView
    el: $('#sample-select')[0]
    collection: datapoints
    displayProperty: 'name'
    selectedCollection: selectedDatapoints
    defaultItem:
      age: 18
    placeholder: 'Enter some names...'

  class TestListView extends Guts.BasicModelView
    tagName: 'li'
    className: 'test-list-item'

  selectionView = new Guts.BaseCollectionView
    el: $('#selection-section')[0]
    item_view_class: TestListView
    collection: selectedDatapoints

# testBackboneSelect2()
