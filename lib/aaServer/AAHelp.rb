# Help module
module AA
  module Help
    def self.help
      puts '
      server.rb options:
      ---------------------
      server.rb [1 op] :
      "-v" or "-version"    : puts Version.
      "-h" or "-help"       : puts Help.
      ---------------------
      server.rb [1..n op] :
      "-s" or "-show"       : show server info: client ip, request and processe time. It slows the server a litle.
      "-dl" or "-debug"      : Show loop info. This mode can be a litle slow!
      "-ds" or "-debug"      : Show server info. This mode is slow!
      "-da" or "-debugAll"  : Show all server info. This mode is really slow!
      "-p NUNBER"           : Use port NUMBER. Default is 41582.'
    end
  end
end
