$(function($) {

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

  // Navbar click
  $(document).on("click", "#search-form .search-button", function (e) {
    $("#search-form input").focus();
    return false;
  });

});
