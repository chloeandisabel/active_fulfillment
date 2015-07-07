require 'thor'
require 'byebug'
require 'nokogiri'
require 'active_fulfillment/models'

# I thought it would be a useful piece of functionality to add.
# Remove it if that's not the case
# See:
#   http://whatisthor.com/

module ActiveFulfillment

  class CLI < Thor

    desc "order", "place an order"
    def order

    end

  end

end
