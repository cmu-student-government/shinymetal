#Dropdown menu for filter name

jQuery ->
  filter_names = $('#filter_filter_name').html()
  # Default to organizations
  default_options = $(filter_names).filter("optgroup[label='organizations']").html()
  $('#filter_filter_name').html(default_options)
  $('#filter_resource').change ->
    resource = $('#filter_resource :selected').text()
    options = $(filter_names).filter("optgroup[label='#{resource}']").html()
    if options
      $('#filter_filter_name').html(options)
    else
      $('#filter_filter_name').empty()