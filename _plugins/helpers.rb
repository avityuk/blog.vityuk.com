module Liquid
  module ExtendedFilters

    def date_to_month(input)
      Date::MONTHNAMES[input]
    end

    def date_to_month_abbr(input)
      Date::ABBR_MONTHNAMES[input]
    end

    def date_to_utc(input)
      input.getutc
    end

    def preview(text, delimiter = '<!-- more -->')
      if text.index(delimiter) != nil
        text.split(delimiter)[0]
      else
        ''
      end
    end
  end
  Liquid::Template.register_filter(ExtendedFilters)
end
