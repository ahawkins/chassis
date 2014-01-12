class String
  def constantize
    Chassis::Inflector.constantize self
  end unless method_defined?(:constantize)

  def demodulize
    Chassis::Inflector.demodulize self
  end unless method_defined?(:demodulize)

  def underscore
    Chassis::Inflector.underscore self
  end unless method_defined?(:underscore)
end
