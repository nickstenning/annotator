# Public: Tags plugin allows users to tag thier annotations with metadata
# stored in an Array on the annotation as tags.
class Annotator.Plugin.Tags extends Annotator.Plugin

  # The field element added to the Annotator.Editor wrapped in jQuery. Cached to
  # save having to recreate it everytime the editor is displayed.
  field: null
  
  # The input element added to the Annotator.Editor wrapped in jQuery. Cached to
  # save having to recreate it everytime the editor is displayed.
  input: null

  # Public: Initialises the plugin and adds custom fields to both the
  # annotator viewer and editor. The plugin also checks if the annotator is
  # supported by the current browser.
  #
  # Returns nothing.
  pluginInit: ->
    return unless Annotator.supported()

    @field = @annotator.editor.addField({
      label:  'Add some tags here\u2026'
      load:   this.updateField
      submit: this.setAnnotationTags
    })

    @annotator.viewer.addField({
      load: this.updateViewer
    })

    # Add a filter to the Filter plugin if loaded.
    if @annotator.plugins.Filter
      @annotator.plugins.Filter.addFilter({
        label: 'Tag'
        property: 'tags'
        isFiltered: (input, tags) ->
          if input and tags?.length
            matched  = 0
            keywords = input.split(/\s+/g)
            for keyword in keywords
              for tag in tags
                if tag.indexOf(keyword) != -1
                  matched += 1

          matched == keywords.length
      })

    @input = $(@field).find(':input')

  # Public: Extracts tags from the provided String.
  #
  # string - A String of tags seperated by spaces.
  #
  # Examples
  #
  #   plugin.parseTags('cake chocolate cabbage')
  #   # => ['cake', 'chocolate', 'cabbage']
  #
  # Returns Array of parsed tags.
  parseTags: (string) ->
    string = $.trim(string)

    tags = []
    tags = string.split(/\s+/) if string
    tags

  # Public: Takes an array of tags and serialises them into a String.
  #
  # array - An Array of tags.
  #
  # Examples
  #
  #   plugin.stringifyTags(['cake', 'chocolate', 'cabbage'])
  #   # => 'cake chocolate cabbage'
  #
  # Returns Array of parsed tags.
  stringifyTags: (array) ->
    array.join(" ")

  # Annotator.Editor callback function. Updates the @input field with the
  # tags attached to the provided annotation.
  #
  # field      - The tags field Element containing the input Element.
  # annotation - An annotation object to be edited.
  #
  # Examples
  #
  #   field = $('<li><input /></li>')[0]
  #   plugin.updateField(field, {tags: ['apples', 'oranges', 'cake']})
  #   field.value # => Returns 'apples oranges cake'
  #
  # Returns nothing.
  updateField: (field, annotation) =>
    value = ''
    value = this.stringifyTags(annotation.tags) if annotation.tags

    @input.val(value)

  # Annotator.Editor callback function. Updates the annotation field with the
  # data retrieved from the @input property.
  #
  # field      - The tags field Element containing the input Element.
  # annotation - An annotation object to be updated.
  #
  # Examples
  #
  #   annotation = {}
  #   field = $('<li><input value="cake chocolate cabbage" /></li>')[0]
  #
  #   plugin.setAnnotationTags(field, annotation)
  #   annotation.tags # => Returns ['cake', 'chocolate', 'cabbage']
  #
  # Returns nothing.
  setAnnotationTags: (field, annotation) =>
    annotation.tags = this.parseTags(@input.val())

  # Annotator.Viewer callback function. Updates the annotation display with tags
  # removes the field from the Viewer if there are no tags to display.
  #
  # field      - The Element to populate with tags.
  # annotation - An annotation object to be display.
  #
  # Examples
  #
  #   field = $('<div />')[0]
  #   plugin.updateField(field, {tags: ['apples']})
  #   field.innerHTML # => Returns '<span class="annotator-tag">apples</span>'
  #
  # Returns nothing.
  updateViewer: (field, annotation) ->
    field = $(field)

    if annotation.tags and $.isArray(annotation.tags) and annotation.tags.length
      field.addClass('annotator-tags').html(->
        string = $.map(annotation.tags,(tag) ->
            '<span class="annotator-tag">' + Annotator.$.escape(tag) + '</span>'
        ).join(' ')
      )
    else
      field.remove()