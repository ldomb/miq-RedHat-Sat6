=begin
 method: List_Locations.rb
 Description: Lists all locations know to satellite6 
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

def get_json(locations)
    response = RestClient::Request.new(
        :method => :get,
        :verify_ssl => $verifyssl,
        :url => locations,
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
activationkey = $evm.root['dialog_param_activationkey']

locations = get_json(url+"locations")
locationslist = {}
locationslist['false'] = false

locations['results'].each do |location|
  puts location['name']
  locationslist[location['name']] = location['name']
end

if activationkey == "ak-Reg_To_Crash_soe_no_puppet"
  locationslist = {}
  locationslist['false'] = false  
end

list_values = {
  'sort_by' => :value,
  'required' => false,
  'values' => locationslist
}



list_values.each { |key, value| $evm.object[key] = value }
$evm.log(:info, "Dialog Values: #{$evm.object['values'].inspect}")



