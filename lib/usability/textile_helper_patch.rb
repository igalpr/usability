module Usability
  module TextileHelperPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method :wikitoolbar_for, :us
        alias_method :heads_for_wiki_formatter, :us
      end
    end
  end
  module InstanceMethods
    def wikitoolbar_for_with_us(field_id, preview_url = preview_text_path)
      res = wikitoolbar_for_without_us(field_id, preview_url)
      res += javascript_tag(" var jst_elem = $('##{field_id}').parent().siblings('.jstElements')
                              var cut_button = jst_elem.find('.jstb_cut');
                              var code_button = jst_elem.find('#space1').get(0);
                              if (cut_button.length && wikiToolbar != undefined){
                                  var cut = cut_button.clone(true, true);
                                  cut_button.remove();
                                  wikiToolbar.draw_button(code_button, 'cut');
                              }
                              var us_color_text_button = jst_elem.find('.jstb_us_color_text');
                              if (us_color_text_button.length && wikiToolbar != undefined){
                                var us_color_text = us_color_text_button.clone(true, true);
                                us_color_text_button.remove();
                                wikiToolbar.draw_button(code_button, 'us_color_text');
                             }")
    end

    def heads_for_wiki_formatter_with_us
      heads_for_wiki_formatter_without_us
      unless @extentions_for_wiki_formatter_included
        content_for :header_tags do
          javascript_include_tag('wiki-extentions.js', :plugin => :usability) +
            javascript_include_tag("jstoolbar-lang/jstoolbar-#{%w(ru en).include?(current_language.to_s.downcase) ? current_language.to_s.downcase : 'en'}.js", :plugin => :usability) +
            stylesheet_link_tag('wiki-extentions.css', :plugin => :usability)
        end
        @extentions_for_wiki_formatter_included = true
      end
    end
  end
end