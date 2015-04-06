$(function($) {
  var alertContainer = $("#alert-container"),
      searchInput = $("input#term");

  // Back to top button js
    $(window).scroll(function() {
      $("#back-to-top").fadeTo("fast", $(this).scrollTop() > 200 ? 1 : -1);
    });

    $(document).on("click", "#back-to-top", function (e) {
      $("html, body").animate( { scrollTop: 0 }, 100);
      return false;
    });

  // Navbar search click
    $(document).on("click", "#search-form .search-button", function (e) {
      $("#search-form input").focus();
      return false;
    });

  // User search
    // For when changing search type (e.g. user, user_key)
    // $("#search-type-select").change(function() { $("#term").val('') });
    var users_search_path = searchInput.data("search-path"),
        users_path = searchInput.data("users-path");

    searchInput.autocomplete({
      delay: 500,
      autoFocus: true,
      serviceUrl: users_search_path,
      paramName: "term",
      onSelect: function(item) { window.location.href = users_path + "/" + item.data; },
      focus: function(e, ui) { ui.item.siblings().removeClass(".autocomplete-selected"); ui.item.addClass(".autocomplete-selected"); }
    });

    // TODO not working..
    // $.widget("ui.autocomplete", $.ui.autocomplete, { _resizeMenu: function() { debugger; return this.menu.element.outerWidth(+searchInput.width + 2); } });

});
