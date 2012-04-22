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
  attr_accessor :video_box
  attr_accessor :video_name
  attr_accessor :video_url
  attr_accessor :video_live_url
  
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
    browser.columnResizingType = NSBrowserUserColumnResizing
  end
  
  def connectToServer(sender)
    @connection_cache[server_name.stringValue] = create_connection("#{server_name.stringValue}.local", server_password.stringValue)
    
    server_box.hidden = true
    selection_index_path = browser.selectionIndexPath
    browser.loadColumnZero
    browser.selectionIndexPath = selection_index_path
  end
  
  def browserClicked(sender)
    item = browser.itemAtIndexPath(browser.selectionIndexPath)

    if item.is_a?(NSNetService) && !@connection_cache.has_key?(item.name)
      show_server_info(item)
    elsif item.is_a?(AirVideo::Client::VideoObject)
      show_video_info(item)
    else
      server_box.hidden = true
      video_box.hidden = true
    end
  end
  
  def openURLInQuickTime(sender)
    `open -a "QuickTime Player" #{video_url.stringValue}`
  end
  
  def openLiveURLInQuickTime(sender)
    `open -a "QuickTime Player" #{video_live_url.stringValue}`
  end
  
  def rootItemForBrowser(browser)
    @net_browser
  end
  
  def browser(browser, numberOfChildrenOfItem:item) 
    return @servers.size if item == @net_browser
    cache_item(item) unless @cache.has_key?(item)
    return count_from_cache(item)
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
  
  private
  def show_video_info(video)
    video_name.stringValue = ''
    video_url.stringValue = ''
    video_live_url.stringValue = ''
    video_box.hidden = false
    video_name.stringValue = video.name
    video_url.stringValue = video.url
    video_live_url.stringValue = video.live_url
  end
  
  def show_server_info(server)
    server_box.hidden = false
    server_name.stringValue = server.name
  end
  
  def cache_item(item)
    if item.is_a?(NSNetService) && @connection_cache.has_key?(item.name)
      @cache[item] = @connection_cache[item.name].ls 
    elsif item.is_a?(AirVideo::Client::FolderObject)
      @cache[item] = item.ls
    end
    @cache[item]
  end
  
  def count_from_cache(item)
    if @cache.has_key?(item) 
      @cache[item].count 
    else
      0
    end
  end
  
  def create_connection(server, password)
    connection = AirVideo::Client.new(server, 45631, password)
    connection.max_width = 2048
    connection.max_height = 2048
    connection
  end
end
