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

@testBackboneSelect2 = ->
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

  selectView = new Backbone.Select2.MultiselectView
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

