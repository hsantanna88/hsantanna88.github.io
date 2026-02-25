source "https://rubygems.org"

gem "jekyll", "~> 4.4"
gem "minimal-mistakes-jekyll"

# Required for Ruby 3.4+ / 4.0 (removed from stdlib)
gem "logger"
gem "csv"
gem "base64"

group :jekyll_plugins do
  gem "jekyll-paginate"
  gem "jekyll-sitemap"
  gem "jekyll-gist"
  gem "jekyll-feed"
  gem "jemoji"
  gem "jekyll-include-cache"
  gem "jekyll-remote-theme"
end

# Windows and JRuby does not include zoneinfo files
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

gem "wdm", :platforms => [:mingw, :x64_mingw, :mswin]
