# require_relative "../../framework/test_suite/istock_test_suite_config"
# require_relative "../../framework/test_suite/istock_test_suite_reports"
# require_relative "../../framework/test_suite/istock_test_suite_error_handling"
# require_relative "../../framework/data/framework_test_case_priorities"
# require_relative "../../framework/browser/istock_browser_layer"
require 'rspec'
require 'crack'
include RSpec::Matchers
# $command_line_args = Array.new(ARGV)
# Before('@broswer_chrome') do
#   @browser_type = 'chrome'
# end

# Before('@legacy_api') do
#   @suite = 'api'
# end
# Before('@browser_off') do
#   @browser_on = false
# end
# Before('@browser_on') do
#   @browser_on = true
# end
# Before('@disable_javascript') do
#   @enable_javascript = false
# end

Before do
  @time_start = Time.now
  # puts "Test started" + @time_start
  # @suite = nil if !(defined? @suite)
  # @browser_type = nil if !(defined? @browser_type)
  # @browser_on = nil if !(defined? @browser_on)
  # @logging = nil
  # @browser_active = false
  # set_framework_cucumber
  # load_config_cucumber
  # initialize_reporting_cucumber
  # load_framework_cucumber
  # set_logging_level_cucumber
  # # startup_initializer()
  # @site_functions.set_typing_speed(:zippy) if @browser_on
end

After do
  # generate_reports_cucumber
end
After do |scenario|
  # error_type = scenario.status
  # name = nil
  # if scenario.is_a? Cucumber::Ast::OutlineTable::ExampleRow
  #   name = scenario.scenario_outline.title + ":" + scenario.to_hash.to_s
  #   save_error_report(error_type,name,scenario.scenario_outline.location) if scenario.failed?
  # else
  #   name = scenario.title
  #   save_error_report(error_type,name,scenario.location) if scenario.failed?
  # end
  # save_time_report_cucumber(error_type, name)

  # if(scenario.failed?)
  #   begin
  #     if @browser_on
  #       save_path = @site_functions.save_screenshot(:name => "html_report_#{scenario.__id__}")
  #       embed(save_path, "image/png", "SCREENSHOT") if !save_path.nil?
  #     end
  #   rescue Exception => ex
  #   end
  # end
  # (@browser.close; @destination.del_firefox_temp_profile) if @browser_on
  # @istock_browser.free_node
end

def save_time_report_cucumber(error_type = "", report)
  time_finish = Time.now
  time_elapsed = time_finish - @time_start
  time_text =  "Time Elapsed for Test"
  case error_type
    when /pass/i
      time_text = "#{time_text}(PASSED)"
      report = report + " (PASSED)"
    when /undefined/i
      time_text = "#{time_text}(UNDEFINED)"
      report = report + " (UNDEFINED)"
    else
      time_text = "#{time_text}(#{error_type.upcase})"
      report = report + " (#{error_type.upcase}) "
  end
  # puts "#{time_text}: #{time_elapsed}\n\n"
  report = report + ": #{@time_start.strftime("%H:%M:%S")}, #{time_finish.strftime("%H:%M:%S")}, #{time_elapsed}"
  @reports.test_time.push report
  @reports.test_grid_node_info.push("IP #{@config.server_ip} Port#{@config.server_port}")
  @reports.total_testsuite_time += time_elapsed
end
def save_error_report(error_info, test_name, location)
  error_node = Hash["error_type"=>"","error_message"=>""]
  error_type = ""
  error_message = {}
  case error_info
    when /fail/i
      browser_dimensions = "browser off"
      @site_functions.save_screenshot if @browser_on
      browser_dimensions = "Width #{@browser.window.size.width} x Height #{@browser.window.size.height}" if @browser_on
      error_type = "failed"
      error_message = {
          "Test name" => test_name,
          "Error" => "Failed",
          "Message" => "Failed",
          "Grid Node Info" => "IP #{@config.server_ip} Port#{@config.server_port}",
          "Browser Window Size" => "#{browser_dimensions}",
          "Location" => location
      }
    else
      raise("unknown error: #{error_info} ")
  end
  error_node["error_type"] = error_type
  error_node["error_message"] = error_message
  @reports.summary.push(error_node)
  return error_type
end

def generate_reports_cucumber
  # puts "\n"
  @reports.output_fail_report_summary
  # @reports.output_known_bugs_report_summary
  # @reports.output_error_report_summary
  # @reports.output_timeout_report_summary
  # @reports.output_omit_report_summary
  # @reports.output_recycled_objects_report_summary
  @reports.output_time_report_summary
  # @reports.output_memory_report_summary
  # @reports.output_XHR_report_summary
end
def set_framework_cucumber
  @suite = "test_suite" if @suite.nil?
  # @browser_type = nil if  @browser_type.nil?
end

def load_config_cucumber()
  case @suite
    when "test_suite","api"
      @config = Istock_Test_Suite_Config::Config.new($command_line_args)
      @config.browser_type = @browser_type unless @browser_type.nil?
      @config.enable_javascript = @enable_javascript if defined?(@enable_javascript)
    else
      raise ArgumantError, ":config => #{@suite}, is an invalid option"
  end
rescue Exception => e
  @error_handling = Istock_Test_Suite_Error_Handling::Error_Handling.new()
  exception = Istock_Test_Suite_Error_Handling::ConfigError.new(e.message,e.backtrace,e.inspect)
  error = @error_handling.check_error(:exception=>exception,:test_name => inspect)
  # puts error["error_message"]
  exit!(error["error_code"])
end

def initialize_reporting_cucumber
  @reports = nil
  @reports = Istock_Test_Suite_Reports::Reports.new(@config)
rescue Exception => e
  @error_handling = Istock_Test_Suite_Error_Handling::Error_Handling.new()
  exception = Istock_Test_Suite_Error_Handling::ReportingError.new(e.message,e.backtrace,e.inspect)
  error = @error_handling.check_error(:exception=>exception,:test_name => inspect)
  # puts error["error_message"]
  exit!(error["error_code"])
end

def load_framework_cucumber
  if @browser_on.nil?
    @browser_on = @config.browser_on
  else
    @config.browser_on = @browser_on
  end
  load_test_suite()
  load_api()
end

def set_logging_level_cucumber
  if @logging == nil then
    @logging = @config.logging
  end
  case @logging
    when "debug"
      @log.level = Logger::DEBUG
    when "warn"
      @log.level = Logger::WARN
    when "error"
      @log.level = Logger::ERROR
    when "fatal"
      @log.level = Logger::FATAL
    when "info"
      @log.level = Logger::INFO
    else
      @log.level = Logger::DEBUG
  end
rescue Exception => e
  @error_handling = Istock_Test_Suite_Error_Handling::Error_Handling.new()
  exception = Istock_Test_Suite_Error_Handling::LoggingError.new(e.message,e.backtrace,e.inspect)
  error = @error_handling.check_error(:exception=>exception,:test_name => inspect)
  error_node = Hash["error_type"=>"","error_message"=>""]
  error_node["error_type"] = "Logging Failure"
  error_node["error_message"] = error["error_message"]
  @reports.summary.push(error_node)
  @reports.output_error_report_summary()
  exit!(error["error_code"])
end

def load_test_suite()
  for tries in 0..2
     @istock_browser = Istock_Browser_Layer::Istock_Browser.new(@config)

     break if @istock_browser.success
  end
  if @istock_browser.success then
    @env = @config.env
    @machine_config = @istock_browser.machine_config
    @browser = @istock_browser.browser
    @browser.window.resize_to(1920,1080) unless @browser.nil?
    @browser_active = @istock_browser.browser_active
    @browsertab = @istock_browser.browsertab
    # @resource = @istock_browser.resource_layer
    @navigation = @istock_browser.navigation_layer
    @objects = @istock_browser.object_layer
    @object = @istock_browser.object_layer
    @file = @istock_browser.data_layer.files
    @data = @istock_browser.data_layer
    @file_data = @istock_browser.data_layer.file_data
    @log = @istock_browser.logs.testlog
    @logs = @log
    @log_master = @istock_browser.logs
    @constants = @istock_browser.constants
    @site_functions = @istock_browser.site_functions
    @databases = @istock_browser.database_layer
    @memcaches = @istock_browser.memcache_layer
    @search_functions = @site_functions
    @user = @istock_browser.data_layer.user_data
    @user_info = @istock_browser.data_layer.user_info_data
    @cart = @istock_browser.data_layer.cart_data
    @cart_list = @istock_browser.data_layer.cart_list_data
    @cart_item = @istock_browser.data_layer.cart_item_data
    @httpwatch = @istock_browser.httpwatch
    @destination = @istock_browser.destination
    @subscription_cart = @istock_browser.data_layer.subscription_sku_data
    @subscription_cart_list = @istock_browser.data_layer.subscription_sku_cart_list_data
    @subscription_cart_cart_data = @istock_browser.data_layer.subscription_sku_cart_data
    @gsp_api_common_functions = GSP_API_Common_Functions.new(@istock_browser,@constants,@site_functions,@log, @file)
    if @browser_on then
      @navigation.goto(:page=>'logout')
    end
    @test_priorities = Istock_Framework_Priorities::Istock_Priorities.new()
  else
    @error_handling = Istock_Test_Suite_Error_Handling::Error_Handling.new()
    e = @istock_browser.exception
    if e.to_s.include?("Different versions of qa_grid_commands.rb are loaded")
      exception = Istock_Test_Suite_Error_Handling::GridCommandsMismatchError.new(e.message,e.backtrace,e.inspect)
    else
      exception = Istock_Test_Suite_Error_Handling::FrameworkError.new(e.message,e.backtrace,e.inspect)
    end
    error = @error_handling.check_error(:exception=>exception,:test_name => self.inspect)
    error_message = error["error_message"]
    # puts error_message
    error_node = Hash["error_type"=>"","error_message"=>""]
    error_node["error_type"] = "Browser Failure"
    error_node["error_message"] = error["error_message"] + {"Grid Node Info:" => "IP #{@config.server_ip} Port#{@config.server_port}"}
    @reports.summary.push(error_node)
    @reports.output_error_report_summary()
    exit!(error["error_code"])
  end
end

def load_api()
  # puts "Loading API Framework"
  require "./framework/browser/machine_config/istock_machine_config"
  require "./framework/browser/call_layer/legacy_helper"
  require "rexml/document"
  require "xmlrpc/client"
  include REXML
  include XMLRPC
  include Istock_Machine_Config
  include Api_Legacy_Layer
  @machine_config = Istock_Machine_Config::Machine_Config.new(@env,@config) unless defined? @machine_config
  @api_legacy = Api_Legacy_Layer::Legacy_Layer.new(@env, @machine_config.domain)
  @api_slave_delay = @machine_config.slave_delay
  @api_username =  @machine_config.username
  @api_username2 =  @machine_config.username2
  @api_other_username = @machine_config.other_username
  @api_password = @machine_config.password
  @api_key =  @machine_config.root_api_key
  @api_key_pp = @machine_config.pp_api_key
  @api_session_string = /\w{32}/
  @api_timestamp = /\d\d\d\d-\d\d-\d\d[T]\d\d:\d\d:\d\d-\d\d:\d\d/
  @api_admin_membername = @machine_config.api_super_admin
  @api_admin_password = @machine_config.api_super_admin_password
  @api_server_connection = Client.new("#{@machine_config.domain}","/webservices/xmlrpc.php",nil,nil,nil,nil,nil,false,180)
  @api_server_connection_opensearch = "#{@machine_config.site_url}","/webservices/opensearch.php?pw=1&c=30&order=Best%20Match&filterContent=true&fileType=Image&exclusiveArtists=true&taxonomy=Exclude%20Vetta&format=atom&q=tree"
  @api_server_secure_connection = Client.new("#{@machine_config.secure_domain}","/webservices/xmlrpc.php",nil,nil,nil,nil,nil,true,180)
  @api_server_secure_uploads_connection = Client.new("#{@machine_config.secure_uploads_domain}","/webservices/xmlrpc.php",nil,nil,nil,nil,nil,true,180)
  @api_upload_image_path = File.join(@site_functions.files_folder, "testimage1.jpg")
  @api_upload_modelRelease_path = File.join(@site_functions.files_folder, "English_Model Release_2010_01.jpg")
end