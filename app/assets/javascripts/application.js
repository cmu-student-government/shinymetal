// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require foundation
//= require cocoon
//= require jQuery.autocomplete
//= require_tree .

$(document).on('page:load', function() { $(document).foundation(); }); // http://stackoverflow.com/a/27385622/2557082

// adds
$(document).on("click", '#key', function() {
    $(this).select();
 })

// On page load
$(function() {
  $(document).foundation();

  // to handle redirect to comments tab after add or delete
  if(window.location.hash){
      $('ul.tabs li a').each(function(){
          var hash = '#' + $(this).attr('href').split('#')[1];
          if (window.location.hash) $('[data-tab] [href="' + hash + '"]').trigger('click.fndtn.tab');
      });
  }
});

