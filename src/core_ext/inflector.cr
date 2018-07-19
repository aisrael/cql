module Inflector
  extend self

  def inflections(locale = :en)
    Inflections.instance(locale)
  end

  def inflections(locale = :en, &block : Inflections -> _)
    yield Inflections.instance(locale)
  end

  abstract class Inflections
    @@inflectors = {
      :en => DefaultInflections.new,
    }

    def self.instance(locale : Symbol)
      @@inflectors[locale] ||= DefaultInflections.new
    end

    @simple_singular_to_plural = {} of String => String
    @simple_plural_to_singular = {} of String => String

    abstract def plural(rule : String | Regex, replacement : String)
    abstract def singular(rule : String | Regex, replacement : String)
    abstract def uncountable(word : String)
    abstract def irregular(singular : String, plural : String)

    abstract def pluralize(singular : String) : String
  end

  class DefaultInflections < Inflections
    @plurals = [] of {Regex, String}
    @singulars = [] of {Regex, String}

    Inflector.inflections(:en) do |inflect|
      inflect.plural(/(.*)wolf$/, "\\1wolves")
      inflect.plural(/(.*)ooth$/, "\\1eeth")
      inflect.plural(/(.*)elf$/, "\\1elves")
      inflect.plural(/(.+)eaf$/, "\\1eaves")
      inflect.plural(/(.+)ife$/, "\\1ives")
      inflect.plural(/(.+)oot$/, "\\1eet")
      inflect.plural(/(.+)z$/, "\\0es")
      inflect.plural(/(.*)ouse$/, "\\1ice")
      inflect.plural(/(.+)ch$/, "\\0es")
      inflect.plural(/(.+)x$/, "\\0es")
      inflect.plural(/(.+)sh$/, "\\0es")
      inflect.plural(/(.*)man$/, "\\1men")
      inflect.plural(/(.+)um$/, "\\1a")
      inflect.plural(/(.+)s$/, "\\0es")
      inflect.plural(/(.+)us$/, "\\1i")
      inflect.plural(/(.+)is$/, "\\1es")
      inflect.plural(/(.+)y$/, "\\1ies")
    end

    def plural(rule : String | Regex, replacement : String)
      if rule.is_a?(String)
        @simple_singular_to_plural[rule] = replacement
      else
        @plurals.unshift({rule, replacement})
      end
    end

    def singular(rule : String | Regex, replacement : String)
      if rule.is_a?(String)
        @simple_plural_to_singular[rule] = replacement
      else
        @singulars.unshift({rule, replacement})
      end
    end

    def uncountable(word : String)
      irregular(word, word)
    end

    def irregular(singular : String, plural : String)
      @simple_singular_to_plural[singular] = plural
      @simple_plural_to_singular[plural] = singular
    end

    Inflector.inflections(:en) do |inflect|
      {{ run("../../etc/read_as_hash", "irregular") }}.each do |singular, plural|
        inflect.irregular(singular, plural)
      end
      {{ run("../../etc/read_as_hash", "uncountable") }}.each do |singular, _plural|
        inflect.uncountable(singular)
      end
    end

    def pluralize(singular : String) : String
      if plural = @simple_singular_to_plural[singular]?
        return plural
      else
        rule = @plurals.find do |pattern, _replacement|
          pattern.match(singular)
        end
        if rule
          pattern, replacement = rule
          return singular.gsub(pattern, replacement)
        end
        return "#{singular}s" # Default, English-rule
      end
    end
  end

  def pluralize(singular, locale = :en)
    inflections(locale).pluralize(singular)
  end
end
