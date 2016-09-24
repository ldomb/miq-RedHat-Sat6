=begin
 method: List_Architectures.rb
 Description: Lists all architectures recorded in satellite6 
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

def get_json(search)
    response = RestClient::Request.new(
        :method => :get,
        :url => search,
        :verify_ssl => false,
        :user => $username,
        :password => $password,
        :headers => { :accept => :json,
        :content_type => :json }
    ).execute
    results = JSON.parse(response.to_str)
end

# Sat6 admin user
$username = nil || $evm.object['username']
# Get Satellite password from model else set it here
$password = nil || $evm.object.decrypt('password')
url = nil || $evm.object['sat6url']
katello_url = nil || $evm.object['katellourl']
$verifyssl = nil || $evm.object['verifyssl']

architectures = get_json(url+"architectures")
architectureslist = {}
architectures['results'].each do |architecture|
  puts architecture['name']
  if architecture['name'] == "x86_64"
    $evm.object['default_value'] = architecture['id']
  end
  architectureslist[architecture['id']] = architecture['name']
end

list_values = {
  'sort_by' => :value,
  'required' => false,
  'default_value' => 'false',
  'values' => architectureslist
}

list_values.each { |key, value| $evm.object[key] = value }
$evm.log(:info, "Dialog Values: #{$evm.object['values'].inspect}")
