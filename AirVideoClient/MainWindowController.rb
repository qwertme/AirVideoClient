#
#  MainWindowController.rb
#  AirVideoClient
#
#  Created by edomenico on 4/20/12.
#  Copyright 2012 __MyCompanyName__. All rights reserved.

require 'rubygems'
require 'airvideo'

class MainWindowController < NSWindowController
  attr_accessor :browser
  attr_accessor :server_box
  attr_accessor :server_name
  attr_accessor :server_password
  
  def initialize
    @net_browser = NSNetServiceBrowser.alloc.init
    @net_browser.delegate = self
    @net_browser.searchForServicesOfType('_airvideoserver._tcp', inDomain:'local')
    @servers = []
    @connection_cache = {}
    @cache = {}
  end
  
  def awakeFromNib
    initialize
  end
  
  def connectToServer(sender)
    @connection_cache[server_name.stringValue] = AirVideo::Client.new("#{server_name.stringValue}.local", 45631, server_password.stringValue)
    server_box.hidden = true
    browser.loadColumnZero
  end
  
  def rootItemForBrowser(browser)
    @net_browser
  end
  
  def browser(browser, numberOfChildrenOfItem:item) 
    if item == @net_browser
      return @servers.size
    elsif item.is_a?(NSNetService) && !@connection_cache.has_key?(item.name)
      server_box.hidden = false
      server_name.stringValue = item.name
      return 0
    elsif !@cache.has_key?(item)
      if item.is_a?(NSNetService) && @connection_cache.has_key?(item.name)
        @cache[item] = @connection_cache[item.name].ls 
      elsif item.is_a?(AirVideo::Client::FolderObject)
        @cache[item] = item.ls
      else
        @cache[item] = []
      end
    end
    
    return @cache[item].count
  end
  
  def browser(browser, child:index, ofItem:item)
    if item == @net_browser
      @servers[index]
    else
      @cache[item][index]
    end
  end
  
  def browser(browser, isLeafItem:item)
    item.is_a?(AirVideo::Client::VideoObject)
  end
  
  def browser(browser, objectValueForItem:item)
    item.name
  end
  
  def netServiceBrowser(netServiceBrowser, didFindService:netService, moreComing:moreDomainsComing)
    @servers << netService
    browser.loadColumnZero
  end
  
end
