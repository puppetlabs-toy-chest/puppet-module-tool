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
      event.stopPropagation();
      return false;
    });
}

// On the mods#_form, autocomplete the :project_issues_url based on the :project_url.
function mod_form_project_issue_tracker_autocomplete() {
  $('.mods_form_action #mod_project_url').blur(function() {
      var homepage_field = $('#mod_project_url');
      var homepage_url = homepage_field.val();

      var issues_field = $('#mod_project_issues_url');
      var issues_url = issues_field.val();

      if (
          typeof(homepage_url) == 'string' &&
          homepage_url.length > 0 &&
          typeof(issues_url) == 'string' &&
          issues_url.length == 0
      ) {
        var github_re = new RegExp('(http://github.com/[^/]+/[^/]+)');
        var matches = homepage_url.match(github_re);
        if (matches) {
          issues_field.val(matches[1] + '/issues');
          issues_field.effect('highlight', {}, 3000);
        }
      }
  });
}

// Activate unobtrusive JavaScript.
$(document).ready(function() {
    mods_list_links();
    mod_form_project_issue_tracker_autocomplete();
});
