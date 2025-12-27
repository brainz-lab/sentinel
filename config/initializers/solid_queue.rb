# Configure Solid Queue for Rails 8.1+ compatibility
# Disable silence_polling to avoid Logger#silence NoMethodError
SolidQueue.silence_polling = false if defined?(SolidQueue)
