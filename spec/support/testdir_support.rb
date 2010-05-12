  require 'fileutils'

  # Return path to temparory directory for testing.
  def testdir
    return @testdir ||= File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'tmp', 'spec'))
  end

  # Create a temporary testing directory, change into it, and execute the
  # +block+. When the block exists, remove the test directory and change back
  # to the previous directory.
  def mktestdircd(&block)
    previousdir = Dir.pwd
    rmtestdir
    FileUtils.mkdir_p(testdir)
    Dir.chdir(testdir)
    block.call
  ensure
    rmtestdir
    Dir.chdir previousdir
  end

  # Remove the temporary test directory.
  def rmtestdir
    FileUtils.rm_rf(testdir) if File.directory?(testdir)
  end

