module FocusHelper

  # Focus the form's +target+ DOM id (e.g. ":foo" focuses the form's "#foo").
  def focus(target)
    return <<-HERE
<script type="text/javascript">
  // Focus a form field
  $(document).ready( function () { $('##{h target.to_s}').focus() } );
</script>
    HERE
  end

end
