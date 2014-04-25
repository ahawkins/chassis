class String
  def constantize
    Chassis::StringUtils.constantize self
  end

  def demodulize
    Chassis::StringUtils.demodulize self
  end

  def underscore
    Chassis::StringUtils.underscore self
  end
end
