require "saucy"

ActionView::Base.send(:include, Saucy::Helper)
Saucy::Image.cache_sizes