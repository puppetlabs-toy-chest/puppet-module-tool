$(document).ready(function () {
  $("section#notice").each(function(){
    var notice = $(this);
    var hidden = $.cookie('hidden');

    if (hidden){
      notice.hide();
    } else {
      var hide_this_link = $(document.createElement('a'));
      hide_this_link
      .text("Hide this Notice")
      .attr("href", "#")
      .click(function(){
        $.cookie('hidden', true, {expires: 7});
        $(this).parents("section#notice").hide();
      });
      
      notice.find(".site-width").append(hide_this_link);
    }
  });
});
