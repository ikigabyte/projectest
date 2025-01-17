local Queue = {}
Queue.__index = Queue

type Queue = {
    first: number,
    last: number,
    items: {number}
}

function Queue.new()
    local self = setmetatable({
        first = 0,
        last = -1,
        items = {}
    }, Queue)

    return self
end

function Queue:push(value)
    self.last = self.last + 1
    self.items[self.last] = value
end

function Queue:pop()
    if self.first > self.last then return nil end
    local value = self.items[self.first]
    self.items[self.first] = nil
    self.first = self.first + 1
    return value
end

function Queue:isEmpty()
    return self.first > self.last
end

return Queue