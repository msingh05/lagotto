# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2012 by Public Library of Science, a non-profit corporation
# http://www.plos.org/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class Twitter < Source
  def parse_data(article, options={})
    result = get_data(article, options)

    return result if result.nil? || result == { events: [], event_count: nil }

    events = []
    execute_search(events, article, options)

    if events.nil?
      nil
    elsif events.empty?
      { events: [], event_count: nil }
    else
      { events: events,
        event_count: events.length,
        event_metrics: get_event_metrics(comments: events.length) }
    end
  end

  def execute_search(events, article, options={})
    query_url = get_query_url(article)
    options[:source_id] = id

    json_data = get_result(query_url, options)

    if json_data.blank?
      events = nil
    else
      results = json_data["rows"]

      results.each do | result |
        event_data = {}

        data = result["value"]

        if data.key?("from_user")
          user = data["from_user"]
          user_name = data["from_user_name"]
          user_profile_image = data["profile_image_url"]
        else
          user = data["user"]["screen_name"]
          user_name = data["user"]["name"]
          user_profile_image = data["user"]["profile_image_url"]
        end

        event_data[:id] = data["id_str"]
        event_data[:text] = data["text"]
        event_data[:created_at] = data["created_at"]
        event_data[:user] = user
        event_data[:user_name] = user_name
        event_data[:user_profile_image] = user_profile_image

        event = {
          :event => event_data,
          :event_url => "http://twitter.com/#{user}/status/#{data["id_str"]}"
        }

        events << event
        event_metrics = { :pdf => nil,
                          :html => nil,
                          :shares => nil,
                          :groups => nil,
                          :comments => events.length,
                          :likes => nil,
                          :citations => nil,
                          :total => events.length }

        { :events => events,
          :event_count => events.length,
          :event_metrics => event_metrics }
      end
    end
  end

  def get_query_url(article)
    if article.doi =~ /^10.1371/
      url % { :doi => article.doi_escaped }
    else
      nil
    end
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"}]
  end
end
