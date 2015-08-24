Dir[File.join(__dir__, "models/dotcom_distribution/*.rb")].each do |path|
  require "active_fulfillment/models/dotcom_distribution/#{File.basename(path).sub(/\.rb$/, '')}"
end
