map = {}

function addToMap(type, data)
    map[string.format("%i.%i.%i", data.x, data.y, data.z)] = type(data)
end

function initMap()
    addToMap(System, sol)
    addToMap(System, asteroid_field)
end
