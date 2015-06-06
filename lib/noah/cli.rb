require 'noah'
require 'thor'
require 'fog'
module Noah
  class CLI < Thor
    desc "red WORD", "red words print." # コマンドの使用例と、概要
    def red(word) # コマンドはメソッドとして定義する
      pp Fog::Network[:openstack].list_ports()
    end
  end
end
