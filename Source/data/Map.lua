import "scenes/StarSystem"
import "scenes/MiningLaser"
import "data/StarSystems"

map = {}

function initMap()
    map["0.0.0"] = StarSystem(sol)
end
