class Hash
  def symbolize_keys
    inject({}) do |memo, pair|
      memo.merge! pair.first.to_sym => pair.last
    end
  end unless method_defined?(:symbolize_keys)
end
