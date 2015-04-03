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
//= require turbolinks
//= require cocoon
//= require foundation
//= require_tree .


$(function() {
  $(document).foundation();
});

// adds 
$(document).on("click", '#key', function() {
    $(this).select();
 })

// On load, hide the organization checkboxes
$(document).ready(function() {
    $('#organization_toggle_panel').hide();
 })

$(document).ready(function(){
    $('#organization_toggle').click(function(){
        $('#organization_toggle_panel').toggle();
    });
});

$(document).ready(function(){
    $('#second_organization_toggle').click(function(){
        $('#organization_toggle_panel').toggle();
    });
});