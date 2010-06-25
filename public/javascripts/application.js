/* # TODO Implement Watches 

$(document).ready(function() {
    watchingForm();
});
function watchingForm() {
    $('#watching form').ajaxForm({dataType: "script"}).find('a').click(function() {
        $(this).parents('form').trigger('submit');
        return false;
    });
    $('#watching .unwatch').click(function() {
        $.ajax({url: $(this).attr('href'),
                type: 'post',
                dataType: "script",
                data: {_method: 'delete'}
               });
        return false;
    });
}

*/

// For the module listings produced by mods#_list, make the individual module backgrounds clickable to make it easier to navigate.
function mods_list_links() {
  $("#mods li[data-mod_link]")
    .click(function (event) {
      mod_link = $(this).attr('data-mod_link');
      if (mod_link) {
        window.location = mod_link;
      }
      event.stopPropogation();
      return false;
    });
}

$(document).ready(function() {
    mods_list_links();
});
