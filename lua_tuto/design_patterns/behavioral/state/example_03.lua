local document = { state = nil, message = "" }

local draft, review, published
review = {}
function review:handle(context, action)
    if action == "approve" then
        context.message = "published"
        context:set_state(published)
    elseif action == "reject" then
        context.message = "needs changes"
        context:set_state(draft)
    else
        context.message = "review required"
    end
end

draft = {}
function draft:handle(context, action)
    if action == "submit" then
        context.message = "sent to review"
        context:set_state(review)
    else
        context.message = "editing"
    end
end

published = {}
function published:handle(context, action)
    context.message = "read-only"
end

function document:set_state(next_state) self.state = next_state end
function document:apply(action) self.state:handle(self, action) end

document:set_state(draft)
document:apply("submit")
assert(document.state == review and document.message == "sent to review")
document:apply("reject")
assert(document.state == draft and document.message == "needs changes")
print(document.state == draft, document.message)
