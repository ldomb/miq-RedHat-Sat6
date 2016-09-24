=begin
 method: List_Organizations.rb
 Description: Lists all Organizations know to satellite6 
 Author: Laurent Domb <laurent@redhat.com>
 License: GPL v3 
-------------------------------------------------------------------------------
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU General Public License for more details.
 You should have received a copy of the GNU General Public License
 along with this program. If not, see <http://www.gnu.org/licenses/>.
-------------------------------------------------------------------------------
=end
require 'rest-client'
require 'json'

begin

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
  organizationslist = {}


  organizations = get_json(url+"organizations")
  organizations['results'].each do |organization|
    puts organization['name']
    organizationslist[organization['name']] = organization['name']
  end

  $evm.object['default_value'],v = organizationslist.first
  list_values = {
    'sort_by'       => :value,
    'required'      => false,
    'values'        => organizationslist
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

