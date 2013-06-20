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

if not Backbone
  throw new Error 'backbone-select2 : error : Backbone should be loaded before me'

Backbone.Select2 = {}
Backbone.Select2.MultiselectView = MultiSelectControlView
