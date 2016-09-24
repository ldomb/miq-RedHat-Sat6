=begin
 method: list_activationkeys.rb
 Description: Lists activationkyes based on organization filter in satellite6
 Author: Laurent Domb <laurent@redhat.com>
 License: GPL v2
-------------------------------------------------------------------------------
miq-RedHat-Sat6
Copyright (C) 2016 Laurent Domb <lauren@redhat.com>

This file is part of miq-RedHat-Sat6.

Miq-RedHat-Sat6 is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 of the License, or
(at your option) any later version.

Miq-RedHat-Sat6 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Miq-RedHat-Sat6.  If not, see <http://www.gnu.org/licenses/>.

-------------------------------------------------------------------------------
=end


require 'rest-client'
require 'json'
begin
  def log(level, msg, update_message=false)
    $evm.log(level,"#{msg}")
  end

  def dump_root()
    $evm.log(:info, "Begin $evm.root.attributes")
    $evm.root.attributes.sort.each { |k, v| log(:info, "\t Attribute: #{k} = #{v}")}
    $evm.log(:info, "End $evm.root.attributes")
    $evm.log(:info, "")
  end

  def get_json(search)
    response = RestClient::Request.new(
        :method       => :get,
        :url          => search,
        :user         => $username,
        :password     => $password,
        :verify_ssl   => $verifyssl,
        :headers      => {
        :accept       => :json,
        :content_type => :json
        }
    ).execute
    results = JSON.parse(response.to_str)
  end

  $username       = nil || $evm.object['username']
  $password       = nil || $evm.object.decrypt('password')
  $verifyssl      = nil || $evm.object['verifyssl']
  url             = nil || $evm.object['sat6url']
  katello_url     = nil || $evm.object['katellourl']
  dialog_hash     = {}
 
  log(:info, "CloudForms Automate Method Started", true)
  dump_root()

  compute_resource_id = $evm.root['dialog_provider_ems_ref']

  computeresources = get_json(url+"compute_resources/#{compute_resource_id}")
  datastores = get_json(url+"compute_resources/#{compute_resource_id}/available_storage_domains")

  log(:info, "COMPUTE: #{computeresources}", true)
  
  provider = computeresources['provider']
  
  if provider == "Vmware"
    datastores["results"].each do | inner_hash |
      datastore = inner_hash["name"]
      dialog_hash[:"#{datastore}"] = "#{datastore}"
    end
  elsif provider == "Ovirt"
    datastores["results"].each do | inner_hash |
      dialog_hash[inner_hash['id']] = inner_hash['name']
    end
  else
    log(:info, "No datastores defined", true)
  end
  
  if dialog_hash.blank?
    log(:info, "No datastores found")
    dialog_hash[nil] = "< No Datastores found >"
  else
    $evm.object['default_value'],v = dialog_hash.first
    dialog_hash[nil] = '< choose a datastore >'
  end

  list_values = {
    'sort_by'       => :value,
    'required'      => false,
    'values'        => dialog_hash
  }

  list_values.each { |key, value| $evm.object[key] = value }

  exit MIQ_OK

rescue RestClient::Exception => err
  $evm.log(:error, "The REST request failed with code: #{err.response.code}") unless err.response.nil?
  $evm.log(:error, "The response body was:\n#{err.response.body.inspect}") unless err.response.nil?
  exit MIQ_STOP
rescue => err
  $evm.log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
  exit MIQ_STOP
end

