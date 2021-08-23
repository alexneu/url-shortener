class FutureTimeValidator < ActiveModel::EachValidator

  def self.compliant?(value)
    value > Time.now
  end

  def validate_each(record, attribute, value)
    unless value.present? && self.class.compliant?(value)
      record.errors.add(attribute, "is not a future time")
    end
  end

end