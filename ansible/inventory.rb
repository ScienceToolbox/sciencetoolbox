#!/usr/bin/env ruby

require "json"
require "dotenv"

class Ansible
  def self.format(data)
    data.each_with_object({}) do |(key, value), hash|
      hash[key] = {
        "hosts": [value],
        "vars": {
          "ansible_ssh_user": "ubuntu"
        }
      }
    end
  end
end

Dotenv.load!(".env.#{ENV["ENV"]}")

data = Ansible.format(
  "webservers":      ENV["ANSIBLE_WEBSERVER_HOST"],
  "databaseservers": ENV["ANSIBLE_DATABASE_HOST"],
)

puts data.to_json
