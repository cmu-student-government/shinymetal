$(function($) {
  var alertContainer = $("#alert-container"),
      searchInput = $("input#term"),
      searchTypeSelector = $("select#search-type-select");

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
    $("#search-type-select").change(function() { $("#term").val('') });

    var users_search_path = searchInput.data("users-search-path"),
        keys_search_path = searchInput.data("keys-search-path");
        users_path = searchInput.data("users-path");
        keys_path = searchInput.data("keys-path");

    searchInput.autocomplete({
      delay: 500,
      autoFocus: true,
      autoSelectFirst: true,
      paramName: "term",
      serviceUrl: function() { return (searchTypeSelector.val() === "users") ? users_search_path : keys_search_path },
      onSelect: function(item) { window.location.href = (searchTypeSelector.val() === "users") ? users_path : keys_path + "/" + item.data; },
      focus: function(e, ui) { ui.item.siblings().removeClass(".autocomplete-selected"); ui.item.addClass(".autocomplete-selected"); }
    });

});
