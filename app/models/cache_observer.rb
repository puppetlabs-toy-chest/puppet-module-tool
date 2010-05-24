class CacheObserver < ActiveRecord::Observer

  # Models to observe
  observe :mod, :release, :user

  # Expire everything.
  def self.expire
    Rails.logger.info("CacheObserver::expire")
    case Rails.cache
    when ActiveSupport::Cache::FileStore
      FileUtils.rm_rf Dir[File.join(Rails.root, 'tmp', 'cache', '*')]
    else
      raise ArgumentError, "Unknown Rails cache storage type: #{Rails.cache.class}"
    end
  end

  # Alias for expiring everything.
  def expire
    self.class.expire
  end

  # What to do if something is changed, e.g. saved or destroyed.
  def after_change(record)
    self.expire
  end

  alias_method :after_save,    :after_change
  alias_method :after_destroy, :after_change

end
