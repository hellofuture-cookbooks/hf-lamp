require 'json'
require 'hashie'

class Chef
  class Recipe
    class HfLamp
      # Parse item values and defaults
      def self.item(node, item)
        r = {}

        # Aliases
        if item.key?('aliases')
          r[:aliases] = item['aliases']
        else
          r[:aliases] = []
        end

        # Any redirects?
        if item.key?('redirects')
          r[:redirects] = item['redirects']
        else
          r[:redirects] = {}
        end

        if item.key?('single-vhost')
          r[:path] = node['hf-lamp']['docroot-dir']
        else
          if item.key?('path')
            r[:path] = node['hf-lamp']['docroot-dir'] + '/' + item['path']
          else
            r[:path] = node['hf-lamp']['docroot-dir'] + '/' + item['host']
          end
        end

        if item.key?('docroot')
          r[:docroot] = r[:path] + '/' + item['docroot']
        elsif node['hf-lamp']['has-web-dir']
          r[:docroot] = r[:path] + '/' + node['hf-lamp']['web-dir']
        else
          r[:docroot] = r[:path]
        end

        if node['hf-lamp']['vagrant']
          r[:vagrant] = true
        else
          r[:vagrant] = false
        end

        # Use default apache users not root

        if item.key?('user')
          r[:user] = item['user']
        else
          r[:user] = node['apache']['user']
        end

        if item.key?('group')
          r[:group] = item['group']
        else
          r[:group] = node['apache']['group']
        end

        if item.key?('composer')
          if item['composer'].key?('dev') && item['composer']['dev']
            r[:composer_dev] = true
          else
            r[:composer_dev] = false
          end
        
          if item['composer'].key('path')
            r[:composer_path] = item['composer']['path']
          else
            r[:composer_path] = r[:path]
          end

          if item['composer'].key('action')
            r[:composer_action] = item['composer']['action']
          else
            r[:composer_action] = :install
          end
        end

        r
      end
    end
  end
end
