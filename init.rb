# hard patch Redmine Application
module RedmineApp
  class Application
    config.exceptions_app = self.routes
  end
end

Redmine::Plugin.register :usability do
  name 'Usability plugin'
  author 'Vladimir Pitin, Danil Kukhlevskiy, Kovalevsky Vasil'
  description 'This is a plugin for Redmine improving behaviour'
  version '2.4.1'
  url 'http://rmplus.pro/redmine/plugins/usability'
  author_url 'http://rmplus.pro/'

  requires_redmine '4.0.0'

  settings partial: 'settings/usability',
           default: { 'usability_progress_bar_type' => 'tiny',
                      'show_sidebar_close_button' => true,
                      'disable_ajax_preloader' => true,
                      'usability_sidebar_gap' => 40,
                      'usability_sidebar_width' => 310,
                      'fast_link_top_page' => {}
           }
end

Rails.application.config.to_prepare do
  require 'usability/view_hooks'

  unless AccountController.included_modules.include?(Usability::AccountControllerPatch)
    AccountController.send :include, Usability::AccountControllerPatch
  end
  unless ApplicationHelper.included_modules.include?(Usability::ApplicationHelperPatch)
    ApplicationHelper.send(:include, Usability::ApplicationHelperPatch)
  end
  unless UsersController.included_modules.include?(Usability::UsersControllerPatch)
    UsersController.send(:include, Usability::UsersControllerPatch)
  end
  unless WelcomeController.included_modules.include?(Usability::WelcomeControllerPatch)
    WelcomeController.send(:include, Usability::WelcomeControllerPatch)
  end
  unless IssuesController.included_modules.include?(Usability::IssuesControllerPatch)
    IssuesController.send(:include, Usability::IssuesControllerPatch)
  end
  unless AttachmentsHelper.included_modules.include?(Usability::AttachmentsHelperPatch)
    AttachmentsHelper.send(:include, Usability::AttachmentsHelperPatch)
  end
  unless AttachmentsController.included_modules.include?(Usability::AttachmentsControllerPatch)
    AttachmentsController.send(:include, Usability::AttachmentsControllerPatch)
  end
  unless ActivitiesController.included_modules.include?(Usability::ActivitiesControllerPatch)
    ActivitiesController.send(:include, Usability::ActivitiesControllerPatch)
  end
  unless Role.included_modules.include?(Usability::RolePatch)
    Role.send(:include, Usability::RolePatch)
  end
  unless Issue.included_modules.include?(Usability::IssuePatch)
    Issue.send(:include, Usability::IssuePatch)
  end
  unless Mailer.included_modules.include?(Usability::MailerPatch)
    Mailer.send :include, Usability::MailerPatch
  end
  unless MembersController.included_modules.include?(Usability::MembersControllerPatch)
    MembersController.send :include, Usability::MembersControllerPatch
  end
  unless ProjectsController.included_modules.include?(Usability::ProjectsControllerPatch)
    ProjectsController.send :include, Usability::ProjectsControllerPatch
  end
  unless Redmine::WikiFormatting::Textile::Helper.included_modules.include?(Usability::TextileHelperPatch)
    Redmine::WikiFormatting::Textile::Helper.send :include, Usability::TextileHelperPatch
  end

  ActionView::Base.send(:include, UsabilityHelper)
  ApplicationController.send(:include, UsabilityHelper)


  Acl::Settings.append_setting('enable_select2_lib', :usability)
  Acl::Settings.append_setting('enable_bootstrap_lib', :usability)
  Acl::Settings.append_setting('enable_javascript_patches', :usability)
  Acl::Settings.append_setting('enable_modal_windows', :usability)
  Acl::Settings.append_setting('enable_font_awesome', :usability)
end

Redmine::WikiFormatting::Macros.register do
  desc "Cut tag to hide big chunks of text under convenient spoiler"
  macro :cut, :parse_args => false do |obj, args, text|
    args = args.split('|')

    html_id = "collapse-#{Redmine::Utils.random_hex(4)}"

    show_label = args[0] || l(:button_show)
    hide_label = args[1] || args[0] || l(:button_hide)
    js = "$('##{html_id}-show, ##{html_id}-hide').toggle(); $('##{html_id}').fadeToggle(150);"
    out = '<div class="wiki-cut">'
    out << link_to_function(show_label, js, :id => "#{html_id}-show", :class => 'collapsible collapsed')
    out << link_to_function(hide_label, js, :id => "#{html_id}-hide", :class => 'collapsible', :style => 'display:none;')
    out << content_tag('div', textilizable(text, :object => obj, :headings => false), :id => html_id, :class => 'collapsed-text', :style => 'display:none;')
    out << '</div>'
    out.html_safe
  end
end

Rails.application.config.after_initialize do
  plugins = { a_common_libs: '2.5.5' }
  plugin = Redmine::Plugin.find(:usability)
  plugins.each do |k,v|
    begin
      plugin.requires_redmine_plugin(k, v)
    rescue Redmine::PluginNotFound => ex
      raise(Redmine::PluginNotFound, "Plugin requires #{k} not found")
    end
  end

  ProjectsHelper.send(:include, Usability::ProjectsHelperPatch) unless ProjectsHelper.included_modules.include?(Usability::ProjectsHelperPatch)
  ActiveSupport::Reloader.to_prepare do
    ProjectsHelper.send(:include, Usability::ProjectsHelperPatch) unless ProjectsHelper.included_modules.include?(Usability::ProjectsHelperPatch)
  end

  Zip.setup do |c|
    c.unicode_names = true
  end
end

unless Redmine::WikiFormatting.included_modules.include?(Usability::WikiFormattingPatch)
  Redmine::WikiFormatting.send(:include, Usability::WikiFormattingPatch)
end