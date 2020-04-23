module Usability
  module AttachmentsHelperPatch
    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do
        alias_method :link_to_attachments, :usability
      end
    end

    module InstanceMethods
      def link_to_attachments_with_usability(container, options = {})
        default = ''

        if container.present? && container.is_a?(Issue) && Setting.plugin_usability['join_attachments_to_group']

          options.assert_valid_keys(:author, :thumbnails)

          options[:thumbnails] = options[:thumbnails] && Setting.thumbnails_enabled?

          attachments = if container.attachments.loaded?
                          container.attachments
                        else
                          container.attachments.preload(:author).to_a
                        end

          if attachments.present?
            options = { editable: container.attachments_editable?, deletable: container.attachments_deletable?, author: true }.merge(options)

            attachments = attachments.inject({}) { |res, it| res[it.us_group_id || 0] ||= []; res[it.us_group_id || 0] << it; res }
            if attachments.keys.size == 1
              default = render(partial: 'attachments/links', locals: { container: container, attachments: attachments.values.flatten, options: options, thumbnails: options[:thumbnails] })
            else
              tabs = []
              attachments.sort_by { |k,v| -(k.to_i) }.each do |it|
                tabs << { name: "version-#{it[0]}", partial: 'usability/attachments_links', label: { default: "#{it[1].last.author.try(:name) || '-'} (#{format_time(it[1].last.created_on)})" }, container: container, attachments: it[1], options: options, thumbnails: options[:thumbnails] }
              end

              default = render_tabs(tabs)
            end
          end

        else
          default = link_to_attachments_without_usability(container, options)
        end

        if Setting.plugin_usability['enable_download_attachments_all_in_one']
          if container.attachments != [] && container.attachments.size > 1 && default.present?
            link_text = link_to(content_tag(:span, l(:label_usability_download_all_in_one, count: container.attachments.size)), { controller: :attachments, action: :download_all, id: container.id, container_type: container.class.to_s }, class: 'icon icon-us-download-all in_link').html_safe
            if default.index('<!-- all_attaches -->')
              default = default.gsub('<!-- all_attaches -->', link_text).html_safe
            else
              default << '<br>'.html_safe
              default << link_text
            end
          end
        end

        default
      end
    end
  end
end

