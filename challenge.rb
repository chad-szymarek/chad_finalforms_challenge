# Provide a solution for each challenge outlined below
# Solutions should be uploaded to a private gist (if this is a problem for some reason just send us the file)
# Solutions should not use an external dependency/library (gem)
# Feel free to use any standard ruby libraries (Ex: date, resolv, ...)
# Feel free to use any external support sites such as (Google, StackOverflow, ...)
# You will find a number of test cases that will help you test your solution at the bottom of this file
# Be sure to design and style your final solution as you would for a production environment

# needed for challenge 2
require "date"
# suggested for challenge 3
require "resolv"



# Challenge 1: Reformat phone numbers
# Convert a phone number to the format 111-222-3333
# All additional digits over 10 are assumed to be the extension
# Basic Example: Formatter.format("phone_number", "1112223333").result == "111-222-3333"
# Basic Example: Formatter.format("phone_number", "111222333344").result == "111-222-3333x44"

# Challenge 2: Reformat dates
# Convert slash separated date strings to Date objects in the format YYYY-MM-DD
# Assume the last digits are the year unless the value has already been formatted
# Unformattable dates should return their original value
# Basic Example: Formatter.format("date", "05/30/08").result == Date.new(2008, 05, 30)
# Basic Example: Formatter.format("date", "not a date").result == "not a date"
class FormatResult
  def initialize(value)
    @result = value
  end
  
  def result
    return @result
  end
end

class Formatter

  # Your code here for challenge 1 and 2
  def self.format(type, value)

    if type == "phone_number"
      value = value.dup
      phone_number = value.gsub(/\D/, "")

      if phone_number.length < 7
        return FormatResult.new(phone_number)

      elsif phone_number.length == 10
        return FormatResult.new(phone_number.insert(3, "-").insert(7, "-"))

      elsif phone_number.length < 10
        return FormatResult.new(phone_number.insert(3, "-"))

      elsif phone_number.length > 10
        p_number = phone_number[0,10]
        p_extra = phone_number[10..-1]
        full_phone_number = p_number.insert(3, "-").insert(7, "-")
        return FormatResult.new("#{p_number}x#{p_extra}")

      end
    end

    if type == "date"
      year_formatter = '%y'
      date_splitter = '/'
      if value.include? "-"
        date_splitter = "-"
      end
      
      parts = value.split(date_splitter)
    
      # If any part is more than 2 characters
      # we assume it's a 4 part year
      parts.each { | part |
        if part.length > 2
          year_formatter = '%Y'
        end
      }
        
      [
        "%m#{date_splitter}%d#{date_splitter}#{year_formatter}",
        "#{year_formatter}#{date_splitter}%m#{date_splitter}%d",
        "%m#{date_splitter}%d",
      ].each { |format|
        begin
          parsed_date =  Date.strptime(value, format)
    
          return FormatResult.new(parsed_date)
        rescue
        end
      }
      
      return FormatResult.new('not a date')
    end 
end



# Challenge 3: Validate email address
# Remember: Solutions should not use an external library (gem)
# This challenge will require an internet connection to perform DNS lookups
# Rules:
# 1. For this challenge, a valid email address username can only contain letters, numbers, dashes, or periods but must start/end with a letter or number)
# 2. A valid email address domain must have an DNS MX record
# - One way this check can be performed is by using the built in ruby Resolv::DNS class
# Basic Example: EmailAddress.new("username@gmail.com").valid? == true
# Basic Example: EmailAddress.new("user@name@gmail.com").valid? == false

class EmailAddress
  # Your code here for challenge 3
  def initialize(email_address)
    @email_address = email_address
  end

  def valid_email_host?(email)
    hostname = email[(email =~ /@/)+1..email.length]
    valid = true
    begin
      Resolv::DNS.new.getresource(hostname, Resolv::DNS::Resource::IN::MX)
    rescue Resolv::ResolvError
      valid = false
    end
    return valid
  end

  def valid?
    username = @email_address.match(/.+?(?=@)/).to_s
    username_pattern = /\A[a-zA-Z0-9\.\-]*\z/
    start_end_pattern = /\A[a-zA-Z0-9]*\z/

    if username.match?(username_pattern)
      if username[0].match?(start_end_pattern) && username[-1].match?(start_end_pattern)
        return valid_email_host?(@email_address)
      end
    end
    return false
  end

end



# Challenge 1: Reformat phone numbers - Tests
puts
puts "#############################"
puts "# format phone_number tests #"
puts "#############################"
{
  "1112223333"               => "111-222-3333",
  "111222333344444"          => "111-222-3333x44444",
  "2223333"                  => "222-3333",
  "223333"                   => "223333", # unformattable
  "Cell: 223333"             => "223333", # unformattable
  "Cell: 111.222.3333"       => "111-222-3333",
  "W: (111) 222 3333 ext 44" => "111-222-3333x44",
}.each do |unformatted_phone_number, expected_result|
  formatted_phone_number = Formatter.format("phone_number", unformatted_phone_number).result
  if formatted_phone_number == expected_result
    puts "PASS - #{unformatted_phone_number.inspect} became #{expected_result.inspect}"
  else
    puts "FAIL - #{unformatted_phone_number.inspect} should be #{expected_result.inspect} but was #{formatted_phone_number.inspect}"
  end
end


# Challenge 2: Reformat dates - Tests
puts
puts "#####################"
puts "# format date tests #"
puts "#####################"
{
  "05/30/08"   => Date.new(2008, 5, 30),
  "5/30/09"    => Date.new(2009, 5, 30),
  "05/30/10"   => Date.new(2010, 5, 30),
  "5/30/11"    => Date.new(2011, 5, 30),
  "05/30/2012" => Date.new(2012, 5, 30),
  "5/30/2013"  => Date.new(2013, 5, 30),
  "2014-05-30" => Date.new(2014, 5, 30), #
  "2015-5-30"  => Date.new(2015, 5, 30),
  Date.today.strftime("%-m-%-d") => Date.today, # default to current year
  Date.today.strftime("%-m/%-d") => Date.today, # default to current year
  "not a date" => "not a date",
}.each do |unformatted_date, expected_result|
  convert_date_to_s_proc = -> (value) { value.is_a?(Date) ? value.to_s : value }
  expected_result = convert_date_to_s_proc.call(expected_result)
  unformatted_date = convert_date_to_s_proc.call(unformatted_date)
  formatted_date = Formatter.format("date", unformatted_date).result
  formatted_date = convert_date_to_s_proc.call(formatted_date)
  if formatted_date == expected_result
    puts "PASS - #{unformatted_date.inspect} became #{expected_result.inspect}"
  else
    puts "FAIL - #{unformatted_date.inspect} should be #{expected_result.inspect} but was #{formatted_date.inspect}"
  end
end


# Challenge 3: Validate email address - Tests
puts
puts "################################"
puts "# validate email address tests #"
puts "################################"
{
  # valid usernames
  "username@gmail.com"        => true,
  "u.s.e.r.n.a.m.e@gmail.com" => true,
  "us-er.na-me@gmail.com"     => true,
  # invalid usernames
  "username-@gmail.com" => false,
  "username.@gmail.com" => false,
  "-username@gmail.com" => false,
  ".username@gmail.com" => false,
  "user!name@gmail.com" => false,
  # invalid domains
  "username@gmail.com@gmail.com" => false,
  "username@domain-without-dns-mx.com" => false,
}.each do |test_email_address, expected_result|
  email_address = EmailAddress.new(test_email_address)
  actual_result = email_address.valid?
  if actual_result == expected_result
    puts "PASS - #{test_email_address.inspect} should be a #{expected_result ? "valid" : "invalid"} email"
  elsif actual_result == !expected_result
    puts "FAIL - #{test_email_address.inspect} should be a #{expected_result ? "valid" : "invalid"} email"
  else
    puts "FAIL - #{test_email_address.inspect} should be a #{expected_result ? "valid" : "invalid"} email but did not get a boolean result (#{actual_result.inspect})"
  end
end
end