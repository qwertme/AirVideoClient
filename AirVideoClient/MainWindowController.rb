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
  
  def initialize
    @net_browser = NSNetServiceBrowser.alloc.init
    @net_browser.delegate = self
    @net_browser.searchForServicesOfType('_airvideoserver._tcp', inDomain:'local')
    @servers = []
    @cache = {}
  end
  
  def awakeFromNib
    initialize
  end
  
  def rootItemForBrowser(browser)
    @net_browser
  end
  
  
  def browser(browser, numberOfChildrenOfItem:item) 
    if item == @net_browser
      return @servers.size
    elsif !@cache.has_key?(item)
      if item.is_a?(NSNetService)
        server = AirVideo::Client.new("#{item.name}.local",45631,'asd092')
        @cache[item] = server.ls
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
    puts netService.name
  end
  
end
