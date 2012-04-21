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
  
  
  def rootItemForBrowser(browser)
    server
  end
  
  
  def browser(browser, numberOfChildrenOfItem:item) 
    unless cache.has_key?(item)
      if item == server
        cache[item] = server.ls
        elsif item.is_a?(AirVideo::Client::FolderObject)
        cache[item] = item.ls
        else
        cache[item] = []
      end
    end
    return cache[item].count
  end
  
  def browser(browser, child:index, ofItem:item)
    cache[item][index]
  end
  
  def browser(browser, isLeafItem:item)
    item.is_a?(AirVideo::Client::VideoObject)
  end
  
  def browser(browser, objectValueForItem:item)
    item.name
  end
  
  private
  
  def server
    @server ||= AirVideo::Client.new('PepitoMac.local',45631,'asd092')
  end
  
  def cache
    @cache ||= {}
  end
end
