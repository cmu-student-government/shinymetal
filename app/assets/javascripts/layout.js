$(function($) {
  var alertContainer = $("#alert-container"),
      searchInput = $("input#term");

  // Back to top button js
    $(window).scroll(function() {
      if ($(this).scrollTop() > 200)
        $("#back-to-top").fadeIn(500);
      else
        $("#back-to-top").fadeOut(500);
      scrollAlert();
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

    // var searchSource = function(req, res) {
    //   $.ajax({
    //     url: path,
    //     dataType: "json",
    //     data: { term: req.term },
    //     success: function(data) {
    //       res($.map(data, function(item) {
    //         return { label: item.name, id: item.id }
    //       }));
    //     }
    //   });
    // }

    var searchSelect =

    $("input#term").devbridgeAutocomplete({
      delay: 500,
      autoFocus: true,
      serviceUrl: users_search_path,
      paramName: "term",
      onSelect: function(e, ui) { window.location.href = users_path + "/" + ui.item.id; }
    });

});
