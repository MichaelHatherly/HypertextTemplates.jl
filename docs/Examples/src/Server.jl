module Server

import ..Routes

import ReloadableMiddleware

function serve()
    ReloadableMiddleware.Server.dev(; router_modules = [Routes])
end

end
