local function query_builder()
    local query = { filters = {} }
    local builder = {}
    function builder:where(key, value) query.filters[key] = value; return self end
    function builder:limit(value) query.limit = value; return self end
    function builder:build()
        assert(query.limit and query.limit > 0, "positive limit is required")
        return { filters = query.filters, limit = query.limit }
    end
    return builder
end
local query = query_builder():where("mode", "arcade"):limit(10):build()
assert(query.filters.mode == "arcade" and query.limit == 10)
print(query.filters.mode, query.limit)
