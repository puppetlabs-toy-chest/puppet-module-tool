namespace :externals do
  desc "Find references to external resources, e.g. stylesheets, javascripts, images"
  task :grep do
    exec "grep -r puppetlabs.com app/ lib/ | grep -v '~:' | grep -v 'externals.rake:' | egrep 'stylesheet|script|img'"
  end

  desc "Download external dependencies from public site, e.g. stylesheets, javascripts, images"
  task :download do
    require 'pathname'
    require 'fileutils'
    require 'net/http'
    require 'uri'

    # Define extenral items that will be downloaded.
    #
    # The data structure is a hash of kinds (e.g., :javascripts) to an arrays of
    # items (e.g. the JavaScript file represented either by a URL or an array with
    # the URL and local name to use).
    externals = {
      :javascripts => [
        ['http://puppetlabs.com/wp-includes/js/jquery/jquery.js?ver=1.3.2', 'jquery-1.3.2.js'],
        'http://puppetlabs.com/wp-content/themes/puppetlabs/javascripts/html5.js',
        'http://puppetlabs.com/wp-content/themes/puppetlabs/javascripts/jquery.localScroll.js',
        'http://puppetlabs.com/wp-content/themes/puppetlabs/javascripts/jquery.serialScroll.js',
        'http://puppetlabs.com/wp-content/themes/puppetlabs/javascripts/jquery.scrollTo.js',
        'http://puppetlabs.com/wp-content/themes/puppetlabs/javascripts/jquery.cookie.js',
        'http://puppetlabs.com/wp-content/themes/puppetlabs/javascripts/fancybox/jquery.fancybox-1.3.1.pack.js',
        'http://puppetlabs.com/wp-content/themes/puppetlabs/javascripts/jquery.validate.min.js',
        'http://puppetlabs.com/wp-content/themes/puppetlabs/javascripts/cufon-yui.js',
        'http://puppetlabs.com/wp-content/themes/puppetlabs/fonts/Klavika_400-Klavika_600.font.js',
        'http://puppetlabs.com/wp-content/themes/puppetlabs/javascripts/ampersands.js',
        'http://puppetlabs.com/wp-content/themes/puppetlabs/javascripts/drop_down.js',
        'http://puppetlabs.com/wp-content/themes/puppetlabs/javascripts/hide_this.js',
        'http://puppetlabs.com/wp-content/themes/puppetlabs/javascripts/white_papers.js',
        'http://puppetlabs.com/wp-content/themes/puppetlabs/javascripts/docs.js',
        'http://puppetlabs.com/wp-content/themes/puppetlabs/javascripts/fancy_zoom.js',
      ],
      :stylesheets => [
        ['http://puppetlabs.com/wp-content/plugins/wp-pagenavi/pagenavi-css.css?ver=2.60', 'pagenavi-2.60.css'],
        'http://puppetlabs.com/wp-content/themes/puppetlabs/javascripts/fancybox/jquery.fancybox-1.3.1.css',
        'http://puppetlabs.com/wp-content/themes/puppetlabs/style.css',
        'http://puppetlabs.com/wp-content/themes/puppetlabs/ie_7.css',
        'http://puppetlabs.com/wp-content/themes/puppetlabs/ie_8.css',
      ],
      :images => [
        'http://puppetlabs.com/images/book.png'
      ],
    }

    puts "#===[ Downloads ]========================================================="
    puts
    output = StringIO.new
    for kind, values in externals
      for value in values
        source_url = value.kind_of?(String) ? value : value[0]
        target_basename = value.kind_of?(String) ? File.basename(source_url) : value[1]
        target_filename = File.expand_path(File.join(File.expand_path(File.dirname(__FILE__)), '..', '..', 'public', kind.to_s, 'externals', target_basename))
        FileUtils.mkdir_p(File.dirname(target_filename))

        case kind
        when :javascripts
          output.puts %{<%= javascript_include_tag "externals/#{target_basename}" %>}
        when :stylesheets
          output.puts %{<%= stylesheet_link_tag "externals/#{target_basename}" %>}
        when :images
          output.puts %{<%= image_tag "externals/#{target_basename}" %>}
        end

        puts "* GET #{source_url} => #{target_filename}"
        url = URI.parse(source_url)
        request = Net::HTTP::Get.new(url.path)
        response = Net::HTTP.start(url.host, url.port) {|http| http.request(request) }
        File.open(target_filename, 'wb') { |h| h.write(response.body) }
      end
    end

    puts "#===[ Output ]============================================================"
    puts
    output.rewind
    puts output.read
  end

  task :fix_refs do
    require 'fileutils'

    for filename in Dir[File.join(RAILS_ROOT, 'public', 'stylesheets', 'externals', '*.css')]
      next if filename =~ /fancybox/
      FileUtils.cp(filename, filename+'.bak')
      data = File.read(filename)
      File.open("#{filename}", "wb") do |h|
        h.write data.gsub(/url\(['"]?(.+?)['"]?\)/, 'url("/\1")')
      end
    end
  end

end
