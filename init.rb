require 'watchers_controller_patch'

Redmine::Plugin.register :optimize_watchers do
  name 'Optimize Watchers plugin'
  author 'Idéematic for NFrance'
  description 'Optimize Watchers new list'
  version '0.0.1'
  author_url 'https://www.ideematic.com'

  if Gem::Version.new("3.0") > Gem::Version.new(Rails.version) then
    Dispatcher.to_prepare do
      # This tells the Redmine version's controller to include the module from the file above.
      WatchersController.send(:include, WatchersControllerPatch)
    end
  else
    # Rails 3.0 implementation.
    Rails.configuration.to_prepare do
      # This tells the Redmine version's controller to include the module from the file above.
      WatchersController.send(:include, WatchersControllerPatch)
    end
  end
end
