class Status < ApplicationRecord
  def ==(other)
    ["alert", "ad", "di", "lhl", "fcc"].each { |k|
      return false if self[k] != other[k]
    }
    return true
  end
end
