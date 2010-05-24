require 'test_helper'
require 'performance_test_help'

# Profiling results for each test method are written to tmp/performance.
class BrowsingTest < ActionController::PerformanceTest
  def setup
    @tag      ||= Factory :tag
    @tag2     ||= Factory :tag
    @tag3     ||= Factory :tag
              
    @user     ||= Factory :user
    @user2    ||= Factory :user
    @user3    ||= Factory :user
              
    @mod      ||= Factory :mod, :owner => @user
    @mod2     ||= Factory :mod, :owner => @user
    @mod3     ||= Factory :mod, :owner => @user
              
    @release  ||= Factory :release, :mod => @mod
    @release2 ||= Factory :release, :mod => @mod
    @release3 ||= Factory :release, :mod => @mod
  end

  def test_root
    get root_path
  end

  def test_home
    get home_path
  end

  def test_mods
    get mods_path
  end

  def test_users
    get users_path
  end

  def test_user_mods
    get user_path(@user)
  end

  def test_user_mod
    get user_mod_path(@mod.owner, @mod)
  end

  def test_user_mod_release
    get user_mod_release_path(@release.owner, @release.mod, @release)
  end

  def test_tags
    get tag_path(@tag)
  end
end
