$(function() {
  var default_options, filter_names;
  filter_names = $('#filter_filter_name').html();
  default_options = $(filter_names).filter("optgroup[label='organizations']").html();
  $('#filter_filter_name').html(default_options);

  return $('#filter_resource').change(function() {
    var options, resource;
    resource = $('#filter_resource :selected').text();
    options = $(filter_names).filter("optgroup[label='" + resource + "']").html();
    if (options) return $('#filter_filter_name').html(options);
    else return $('#filter_filter_name').empty();
  });

});
