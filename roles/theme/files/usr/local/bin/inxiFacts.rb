#!/usr/bin/env ruby

require 'fileutils'
require 'json'

# Define the output file path in the /tmp directory
output_file = '/tmp/inxiGraphics.json'
FileUtils.rm(output_file) if File.exist?(output_file)


# Run the shell command and capture the output
inxiOutput = `/usr/bin/inxi -G --display -c`

# Create a hash to hold the extracted information
output_hash = { "Graphics" => {} }

# Process the output to extract the relevant information
devices = inxiOutput.scan(/Device-.*: (.*?) driver:/).flatten

devices.each_with_index do |device, index|
  next if device =~ /Camera|cam/
  output_hash["Graphics"]["Device-#{(index + 1).to_s}"] = device
end

# Convert the hash to JSON format
json_output = JSON.pretty_generate(output_hash)

# Write the JSON data to the output file
File.write(output_file, json_output)
