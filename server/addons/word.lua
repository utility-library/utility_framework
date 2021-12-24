local self = {
    GetAllWord = function(string)
        local i = 0
        local self = {
            word = {},
            index = {}
        }
        self.__index = self
        
        --// Index and word
        for word in (string):gmatch("%w+") do 
            i = i + 1
            self.word[word] = i 
            self.index[i] = word 
        end
        
        --// Methods
        self.before = function(self, word)
            return self.index[self.word[word] - 1]
        end
        
        self.after = function(self, word)
            return self.index[self.word[word] + 1]
        end
        
        self.find = function(self, word)
            if type(word) == "string" then
                return self.word[word]
            else
                return self.index[word]
            end
        end

        self.findb = function(self, word)
            if type(word) == "string" then
                return (self.word[word] ~= nil)
            else
                return (self.index[word] ~= nil)
            end
        end
        
        self.base = string        
        return setmetatable({}, self)
    end
}

return self