class String
  def to_bool
    return true   if self == true   || self =~ (/(true|t|yes|y|1|はい)$/i)
    return false
  end
end
