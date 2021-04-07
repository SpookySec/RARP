require "colorize"

module Utils
	BANNER = '''
   _____    _____    _____    _____   
  (, /   ) (, /  |  (, /   ) (, /   ) 
    /__ /    /---|    /__ /   _/__ /  
 ) /   \_ ) /    |_) /   \_   /       
(_/      (_/      (_/      ) /        
                          (_/   
        .: @spooky_sec :.

'''
	CMDS = %w(help config scan hosts quit attack info clear)
	PROMPT = "(rarp) ".colorize(:red)
end