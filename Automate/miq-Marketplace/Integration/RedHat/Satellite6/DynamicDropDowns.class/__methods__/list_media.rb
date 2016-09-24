=begin
 method: List_Media.rb
 Description: Lists all media know to satellite6 
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
  operatingsystemslist = {}
  medialist = {}


  operatingsystem_id =  $evm.root['dialog_operatingsystem_ems_ref']


  operatingsystems = get_json(url+"operatingsystems/#{operatingsystem_id}")

  osname = operatingsystems["fullname"]
  medias = get_json(url+"media")
  medias['results'].each do | osmedia |
    id = osmedia['id']
    os = get_json(url+"media/#{id}")
    os["operatingsystems"].each do | osmedianame |
      fullname = osmedianame["fullname"]
      if "#{fullname}" == "#{osname}"
        medialist[osmedia['name']] = fullname
      end
    end
  end


  medialist[nil] = '< choose your media >'

  list_values = {
    'sort_by'       => :value,
    'required'      => false,
    'values'        => medialist
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

