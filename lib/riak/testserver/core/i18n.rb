require 'i18n'

I18n.enforce_available_locales = true
Dir.glob(File.expand_path("../../locale/*.yml", __FILE__)).each do |locale_file|
  I18n.load_path << locale_file
end
