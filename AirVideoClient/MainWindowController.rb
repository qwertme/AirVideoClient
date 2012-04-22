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
    @connection_cache[server_name.stringValue] = AirVideo::Client.new("#{server_name.stringValue}.local", 45631, server_password.stringValue)
    @connection_cache[server_name.stringValue].max_width = 2048
    @connection_cache[server_name.stringValue].max_height = 2048
    server_box.hidden = true
    selection_index_path = browser.selectionIndexPath
    browser.loadColumnZero
    browser.selectionIndexPath = selection_index_path
  end
  
  def browserClicked(sender)
    item = browser.itemAtIndexPath(browser.selectionIndexPath)

    if item.is_a?(NSNetService) && !@connection_cache.has_key?(item.name)
      showServerInfo(item)
    elsif item.is_a?(AirVideo::Client::VideoObject)
      showVideoInfo(item)
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
    if item == @net_browser
      return @servers.size
    elsif !@cache.has_key?(item)
      if item.is_a?(NSNetService) && @connection_cache.has_key?(item.name)
        @cache[item] = @connection_cache[item.name].ls 
      elsif item.is_a?(AirVideo::Client::FolderObject)
        @cache[item] = item.ls
      end
    end
    
    return @cache.has_key?(item) ? @cache[item].count : 0
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
  def showVideoInfo(video)
    video_name.stringValue = ''
    video_url.stringValue = ''
    video_live_url.stringValue = ''
    video_box.hidden = false
    video_name.stringValue = video.name
    video_url.stringValue = video.url
    video_live_url.stringValue = video.live_url
  end
  
  def showServerInfo(server)
    server_box.hidden = false
    server_name.stringValue = server.name
  end
end
