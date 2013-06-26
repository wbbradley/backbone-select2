class MultiselectView extends Backbone.View
  formatter: =>
    if typeof @options.displayProperty is 'string'
      displayProperty = @options.displayProperty
      (item) ->
        _.result item, displayProperty
    else
      throw new Error 'MultiselectView : error : you must define the displayProperty in your model to show in the dropdown'

  initialize: (options) =>
    @options = options
    if not @options?.collection
      throw new Error 'MultiselectView : error : needs a collection'
    if not @options?.selectedCollection?.model
      throw new Error 'MultiselectView : error : you must provide a collection to store the selected objects'

    # select2 needs some room to create siblings, create a child placeholder
    @$el.html "<div style='width:100%' class='select2-placeholder'></div>"

    @$select = @$('.select2-placeholder').select2
      multiple: true
      # default prevention of the automatic setting of width for now
      id: do =>
        id_name = @options.id
        (item) ->
          id = _.result item, id_name or 'id'
          if id then id else _.result item, '_id'
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
        searchChoice = _.extend {}, @options.defaultItem, _id: _.uniqueId 'n'
        searchChoice[@options.displayProperty] = term
        return searchChoice
      placeholder: @options.placeholder
    @$select.select2 'data', @options.selectedCollection.toJSON()

    # watch the selected collection
    @listenTo @options.selectedCollection, 'add', @updateSelectOptionsData
    @listenTo @options.selectedCollection, 'remove', @updateSelectOptionsData
    @listenTo @options.selectedCollection, 'sync', @updateSelectOptionsData
    @$select.change @onChange
    return

  updateSelectOptionsData: (eventName) =>
    selectedItems = @options.selectedCollection.toJSON()
    for item in selectedItems
      if 'id' not of item
        item._id = item._id or _.uniqueId 'n'

    @$select.select2 'data', selectedItems
    return

  onChange: (event) =>
    if event.added
      itemMatching = @options.selectedCollection.findWhere {id: event.added.id}
      if itemMatching
        throw new Error 'MultiselectView : error : attempt to add item to selectedCollection that already exists'
      model = new @options.selectedCollection.model _.omit event.added, '_id'
      @options.selectedCollection.add model
      @options.selectedCollection.trigger 'select2:add', model
    if event.removed
      itemToRemove = @options.selectedCollection.findWhere {id: event.removed.id}
      if not itemToRemove
        throw new Error 'MultiselectView : error : change event occurred but selectedCollection is not in sync'
      @options.selectedCollection.remove itemToRemove
      @options.selectedCollection.trigger 'select2:remove', itemToRemove

if not Backbone
  throw new Error 'backbone-select2 : error : Backbone should be loaded before me'

Backbone.Select2 = {}
Backbone.Select2.MultiselectView = MultiselectView
