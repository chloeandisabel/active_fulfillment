require 'test_helper'

class StringNormalizerTets < Minitest::Test
  include ActiveFulfillment::DotcomDistribution::StringNormalizer

  def setup
    @field = :color
    @max_len = ActiveFulfillment::DotcomDistribution::StringNormalizer::MAX_LENGTHS[:color]
    @s = "thisstringismuchtoolong"
  end

  def test_truncation
    assert_equal @s[0, @max_len], normalize(@s, @field)
  end

  def test_truncation_no_such_field
    assert_equal @s, normalize(@s, :no_such_field)
  end

  def test_remove_non_ascii
    s = "Cuvé"
    assert_equal "Cuv", normalize(s, @field)
  end

  def test_remove_non_ascii_and_truncate
    s = "Cuvé" + @s
    assert_equal "Cuv#@s"[0, @max_len], normalize(s, @field)
  end
end
