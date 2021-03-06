class CivilService::Service
  include ActiveModel::Validations

  attr_writer :logger

  class << self
    attr_accessor :validate_manually
    attr_writer :result_class

    def result_class
      @result_class || CivilService::Result
    end
  end

  def call
    unless self.class.validate_manually
      return failure(errors) unless valid?
    end

    begin
      inner_call
    rescue StandardError => exception
      errors.add :base, exception.message
      failure(errors, exception: exception)
    end
  end

  def call_and_raise
    result = call
    if result.exception
      raise result.exception, result.exception.message, result.exception.backtrace
    end

    result
  end

  def call!
    unless self.class.validate_manually
      raise CivilService::ServiceFailure.new(self, failure(errors)) unless valid?
    end

    result = call_and_raise
    raise CivilService::ServiceFailure.new(self, result) if result.failure?
    result
  end

  def logger
    @logger || Rails.logger
  end

  private

  def success(attributes = {})
    self.class.result_class.success(attributes)
  end

  def failure(errors, attributes = {})
    self.class.result_class.failure(attributes.merge(errors: errors))
  end

  def inner_call
    raise 'Service classes are expected to implement #inner_call'
  end
end
