require "./inflections"

module Inflector
  extend self

  def inflections(locale = :en)
    Inflections.instance(locale)
  end

  def inflections(locale = :en, &block : Inflections -> _)
    yield Inflections.instance(locale)
  end

  def pluralize(singular, locale = :en)
    inflections(locale).pluralize(singular)
  end
end
